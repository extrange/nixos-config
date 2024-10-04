{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.uptime = {
    enable = mkEnableOption "Ping an Uptime Kuma webhook";
    url = mkOption {
      type = types.nonEmptyStr;
      description = "The webhook url to ping";
      example = "https://uptime.icybat.com/api/push/abc123def?status=up&msg=OK&ping=";
      default = null;
    };
    frequency = mkOption {
      type = types.nonEmptyStr;
      description = "Frequency to call the webhook, in systemd calendar format. Default every 5 mins.";
      example = "*-*-* *:00/5:00";
      default = "*-*-* *:00/5:00";
    };
  };

  config = mkIf config.uptime.enable {
    systemd.services.uptime = {
      description = "Uptime Kuma Ping";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.curl}/bin/curl -sS ${config.uptime.url}";
      };
    };
    systemd.timers.uptime = {
      description = "Uptime Kuma Ping";
      timerConfig = {
        OnCalendar = config.uptime.frequency;
      };
      wantedBy = [ "timers.target" ];
    };

  };
}
