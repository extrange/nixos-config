# Central Prometheus/Loki/Grafana stack for the tailnet.
{
  config,
  ...
}:
let
  acmeDomain = "internal.nicholaslyz.com";
  grafanaAlerting = import ./grafana/alerting.nix;
in
{
  sops.secrets = {
    "acme/cloudflare" = {
      owner = "acme";
      mode = "0400";
    };
    "grafana/admin_password" = {
      owner = "grafana";
      mode = "0400";
    };
    "grafana/secret_key" = {
      owner = "grafana";
      mode = "0400";
    };
    "grafana/smtp_password" = {
      owner = "grafana";
      mode = "0400";
    };
    "grafana/telegram_uptime_bot_token" = {
      restartUnits = [ "grafana.service" ];
    };
    "grafana/telegram_relationship_manager_bot_token" = {
      restartUnits = [ "grafana.service" ];
    };
  };

  systemd.services.grafana.serviceConfig.EnvironmentFile = [
    config.sops.secrets."grafana/telegram_uptime_bot_token".path
    config.sops.secrets."grafana/telegram_relationship_manager_bot_token".path
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "acme@nicholaslyz.com";
    certs."${acmeDomain}" = {
      domain = "*.${acmeDomain}";
      dnsProvider = "cloudflare";
      environmentFile = config.sops.secrets."acme/cloudflare".path;
    };
  };

  services.caddy = {
    enable = true;
    httpPort = null;
    virtualHosts = {
      "grafana.internal.nicholaslyz.com" = {
        useACMEHost = acmeDomain;
        extraConfig = "reverse_proxy 127.0.0.1:3000";
      };
      "prometheus.internal.nicholaslyz.com" = {
        useACMEHost = acmeDomain;
        extraConfig = "reverse_proxy 127.0.0.1:9090";
      };
    };
  };

  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;

      server = {
        http_listen_address = "0.0.0.0";
        http_listen_port = 3100;
        # Fixes grpc: received message larger than max errors
        # https://github.com/grafana/loki/issues/2271
        grpc_server_max_recv_msg_size = 104857600; # 100MB
        grpc_server_max_send_msg_size = 104857600; # 100MB
      };

      schema_config.configs = [
        {
          from = "2024-01-01";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }
      ];

      common = {
        path_prefix = "/var/lib/loki";
        replication_factor = 1;
        compactor_address = "http://127.0.0.1:3100";
        # Single-node Loki. Without an explicit ring store Loki defaults to
        # Consul and fails to start unless Consul or memberlist is configured.
        ring.kvstore.store = "inmemory";
      };

      compactor = {
        working_directory = "/var/lib/loki/compactor";
        retention_enabled = true;
        delete_request_store = "filesystem";
        retention_delete_delay = "2h";
        compaction_interval = "10m";
        apply_retention_interval = "0";
      };

      limits_config = {
        retention_period = "672h"; # 28 days
        # Devices may replay buffered logs after being offline; retention
        # still deletes anything older than retention_period.
        reject_old_samples = false;
      };

      storage_config = {
        tsdb_shipper = {
          active_index_directory = "/var/lib/loki/tsdb-index";
          cache_location = "/var/lib/loki/tsdb-cache";
        };
        filesystem.directory = "/var/lib/loki/data";
      };
    };
  };

  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 9090;
    retentionTime = "30d";
    extraFlags = [ "--storage.tsdb.retention.size=20GB" ];
    webExternalUrl = "https://prometheus.internal.nicholaslyz.com/";
    globalConfig = {
      scrape_interval = "15s";
      evaluation_interval = "15s";
    };

    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [ { targets = [ "127.0.0.1:9090" ]; } ];
      }
      {
        job_name = "node";
        static_configs = [
          {
            targets = [
              "127.0.0.1:9100" # io
              "server:9100"
              "desktop:9100"
              "laptop:9100"
            ];
          }
        ];
      }
      {
        job_name = "cadvisor";
        static_configs = [ { targets = [ "server:18080" ]; } ];
      }
      {
        job_name = "smartctl";
        static_configs = [ { targets = [ "server:9633" ]; } ];
      }
      {
        job_name = "loki";
        static_configs = [ { targets = [ "127.0.0.1:3100" ]; } ];
      }
    ];
  };

  services.grafana = {
    enable = true;

    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        domain = "grafana.internal.nicholaslyz.com";
        root_url = "https://grafana.internal.nicholaslyz.com/";
        enforce_domain = true;
      };

      analytics.reporting_enabled = false;

      security = {
        admin_user = "admin";
        # Grafana 13 has no default for either of these; both must be
        # provided via the file provider.
        admin_password = "$__file{${config.sops.secrets."grafana/admin_password".path}}";
        secret_key = "$__file{${config.sops.secrets."grafana/secret_key".path}}";
      };

      smtp = {
        enabled = true;
        host = "smtp.forwardemail.net:465";
        user = "grafana-alerts@nicholaslyz.com";
        from_address = "grafana-alerts@nicholaslyz.com";
        password = "$__file{${config.sops.secrets."grafana/smtp_password".path}}";
      };
    };

    provision = {
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          uid = "edzyobdoyzzeoa";
          access = "proxy";
          url = "http://127.0.0.1:9090";
          isDefault = true;
          editable = false;
          jsonData = {
            httpMethod = "POST";
            prometheusType = "Prometheus";
            timeInterval = "15s";
          };
        }
        {
          name = "Loki";
          type = "loki";
          uid = "de1ql679ixla8e";
          access = "proxy";
          url = "http://127.0.0.1:3100";
          editable = false;
        }
      ];

      alerting = {
        templates.settings = grafanaAlerting.templates;
        policies.settings = grafanaAlerting.policies;
        rules.settings = grafanaAlerting.rules;
        # Grafana expands the $GRAFANA_TELEGRAM_* variables from the service
        # EnvironmentFile, so the tokens stay out of the Nix store.
        contactPoints.settings = {
          apiVersion = 1;
          contactPoints = [
            {
              orgId = 1;
              name = "nicholas-telegram";
              receivers = [
                {
                  uid = "edzubi7005m9sc";
                  type = "telegram";
                  disableResolveMessage = false;
                  settings = {
                    bottoken = "$GRAFANA_TELEGRAM_UPTIME_BOT_TOKEN";
                    chatid = "427380463";
                    disable_notification = false;
                    disable_web_page_preview = false;
                    message = ''{{ template "telegram.default.message" . }}'';
                    protect_content = false;
                  };
                }
              ];
            }
            {
              orgId = 1;
              name = "Relationship Manager";
              receivers = [
                {
                  uid = "aenglmwixlq0wb";
                  type = "telegram";
                  disableResolveMessage = true;
                  settings = {
                    bottoken = "$GRAFANA_TELEGRAM_RELATIONSHIP_MANAGER_BOT_TOKEN";
                    chatid = "-1001787634126";
                    disable_notification = false;
                    disable_web_page_preview = false;
                    message = ''{{ template "custom.summary_only" . }}'';
                    parse_mode = "None";
                    protect_content = false;
                  };
                }
              ];
            }
            {
              orgId = 1;
              name = "nicholas-email";
              receivers = [
                {
                  uid = "ddzubn8ot9xq8e";
                  type = "email";
                  disableResolveMessage = false;
                  settings = {
                    addresses = "me@nicholaslyz.com";
                    singleEmail = false;
                  };
                }
              ];
            }
          ];
        };
      };

      dashboards.settings.providers = [
        {
          name = "default";
          type = "file";
          allowUiUpdates = false;
          disableDeletion = true;
          updateIntervalSeconds = 30;
          options.path = ./grafana/dashboards;
        }
      ];
    };
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    443 # Caddy (Grafana + Prometheus)
    3100 # Loki ingest
  ];
}
