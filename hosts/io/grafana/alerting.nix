# Declarative Grafana alerting configuration.
#
# Alert rules, notification policies and templates are passed to
# services.grafana.provision.alerting in ../monitoring.nix. Contact points are
# rendered from sops because they contain Telegram bot tokens.
#
# The rules preserve the old Grafana rules, with two fixes:
#   - Factorio logs are labelled with the full compose container name
#     (server-factorio-1), which is what Vector records.
#   - Grafana now runs on io and logs to journald, so the Grafana Errors rule
#     queries host=io journald instead of the retired server container.
let
  lokiUid = "de1ql679ixla8e";

  mkData =
    {
      from,
      expr,
      thresholdParams,
      thresholdType,
    }:
    [
      {
        refId = "A";
        queryType = "range";
        relativeTimeRange = {
          inherit from;
          to = 0;
        };
        datasourceUid = lokiUid;
        model = {
          editorMode = "builder";
          inherit expr;
          instant = true;
          intervalMs = 1000;
          maxDataPoints = 43200;
          queryType = "range";
          refId = "A";
        };
      }
      {
        refId = "reducer";
        queryType = "expression";
        relativeTimeRange = {
          from = 0;
          to = 0;
        };
        datasourceUid = "__expr__";
        model = {
          conditions = [
            {
              evaluator = {
                params = [
                  0
                  0
                ];
                type = "gt";
              };
              operator.type = "and";
              query.params = [ ];
              reducer = {
                params = [ ];
                type = "count";
              };
              type = "query";
            }
          ];
          datasource = {
            name = "Expression";
            type = "__expr__";
            uid = "__expr__";
          };
          expression = "A";
          intervalMs = 1000;
          maxDataPoints = 43200;
          reducer = "count";
          refId = "reducer";
          type = "reduce";
        };
      }
      {
        refId = "C";
        queryType = "";
        relativeTimeRange = {
          from = 0;
          to = 0;
        };
        datasourceUid = "__expr__";
        model = {
          conditions = [
            {
              evaluator = {
                params = thresholdParams;
                type = thresholdType;
              };
              operator.type = "and";
              query.params = [ "C" ];
              reducer = {
                params = [ ];
                type = "last";
              };
              type = "query";
            }
          ];
          datasource = {
            type = "__expr__";
            uid = "__expr__";
          };
          expression = "reducer";
          intervalMs = 1000;
          maxDataPoints = 43200;
          refId = "C";
          type = "threshold";
        };
      }
    ];

  mkRule =
    {
      uid,
      title,
      from,
      expr,
      thresholdParams,
      thresholdType,
      annotations ? { },
      labels ? { },
      noDataState,
      execErrState,
    }:
    {
      inherit
        uid
        title
        annotations
        labels
        noDataState
        execErrState
        ;
      condition = "C";
      for = "0s";
      data = mkData {
        inherit
          from
          expr
          thresholdParams
          thresholdType
          ;
      };
    };
in
{
  templates = {
    apiVersion = 1;
    templates = [
      {
        orgId = 1;
        name = "Summary Only";
        template = ''
          {{ define "custom.summary_only" }}{{ range .Alerts.Firing }}
          {{ .Annotations.summary }}{{ end }}{{ end }}
        '';
      }
    ];
  };

  policies = {
    apiVersion = 1;
    policies = [
      {
        orgId = 1;
        receiver = "nicholas-telegram";
        group_by = [
          "grafana_folder"
          "alertname"
        ];
        group_wait = "5s";
        group_interval = "5s";
        repeat_interval = "8760h"; # was 1y
        routes = [
          {
            receiver = "Relationship Manager";
            matchers = [ "notify = relationship_manager" ];
          }
          {
            receiver = "nicholas-email";
            matchers = [ "notify = email" ];
          }
        ];
      }
    ];
  };

  rules = {
    apiVersion = 1;
    groups = [
      {
        orgId = 1;
        name = "Factorio";
        folder = "Factorio";
        interval = "300s";
        rules = [
          (mkRule {
            uid = "cenggrvw8ba4gb";
            title = "Factorio new player";
            from = 300;
            expr = ''count_over_time({container_name="server-factorio-1"} | json | regexp `\[(LEAVE|JOIN)\] (?<player>.*(left|joined) the game)` | player != `` [$__auto])'';
            thresholdParams = [ 0 ];
            thresholdType = "gt";
            annotations.summary = "Factorio: {{ $labels.message }}";
            labels.notify = "relationship_manager";
            noDataState = "NoData";
            execErrState = "Error";
          })
        ];
      }
      {
        orgId = 1;
        name = "Server";
        folder = "Server";
        interval = "3600s";
        rules = [
          (mkRule {
            uid = "eep2zrmeg581sa";
            title = "BTRFS Errors";
            from = 3600;
            expr = ''count_over_time({source_type="journald"} |~ `(?i)BTRFS error` [$__auto])'';
            thresholdParams = [ 1 ];
            thresholdType = "gte";
            noDataState = "OK";
            execErrState = "Error";
          })
          (mkRule {
            uid = "eep4ryp59utxca";
            title = "Grafana Errors";
            from = 3600;
            expr = ''count_over_time({host="io", source_type="journald"} |= "alertmanager" |= "level=error" [$__auto])'';
            thresholdParams = [ 0 ];
            thresholdType = "gt";
            labels.notify = "email";
            noDataState = "OK";
            execErrState = "Error";
          })
        ];
      }
    ];
  };
}
