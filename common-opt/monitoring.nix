# Ship journald logs to Loki and expose node-exporter to the monitoring server.
#
# The central Prometheus/Loki/Grafana stack lives on `io` (see
# hosts/io/monitoring.nix).
{
  config,
  lib,
  ...
}:
let
  cfg = config.monitoring.client;
in
{
  options.monitoring.client = {
    enable = lib.mkEnableOption "ship journald logs and expose node-exporter to the monitoring server";

    serverAddress = lib.mkOption {
      type = lib.types.str;
      default = "io.tail96daa.ts.net";
      description = "Tailnet DNS name (or IP) of the Loki endpoint on io.";
      example = "100.98.57.58";
    };

    lokiPort = lib.mkOption {
      type = lib.types.port;
      default = 3100;
      description = "Port the Loki HTTP API listens on.";
    };

    bufferSize = lib.mkOption {
      type = lib.types.int;
      default = 512 * 1024 * 1024;
      description = "Maximum size of the on-disk Vector buffer in bytes.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.prometheus.exporters.node = {
      enable = true;
      listenAddress = "0.0.0.0";
      port = 9100;
    };

    # Only the tailnet may scrape the exporter.
    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 9100 ];

    services.vector = {
      enable = true;
      journaldAccess = true;
      settings = {
        acknowledgements = true;
        data_dir = "/var/lib/vector";

        sources.journald = {
          type = "journald";
          since_now = true;
        };

        transforms.add_host = {
          type = "remap";
          inputs = [ "journald" ];
          source = ".host = \"${config.networking.hostName}\"";
        };

        sinks.loki = {
          type = "loki";
          inputs = [ "add_host" ];
          endpoint = "http://${cfg.serverAddress}:${toString cfg.lokiPort}";
          encoding.codec = "json";
          labels = {
            host = "{{ host }}";
            source = "{{ source_type }}";
          };
          # Buffer through io/network outages instead of dropping logs.
          buffer = {
            type = "disk";
            max_size = cfg.bufferSize;
          };
        };
      };
    };
  };
}
