{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
{
  options.fixLogiBoltSleep = mkEnableOption "Fixes for Logitech Bolt/Unifying receivers waking the PC from sleep";

  config = mkIf config.fixLogiBoltSleep {
    # Adds udev rules for solaar.
    # Note that you need to replug+repair the keyboard for the first time
    # https://github.com/3v1n0/Solaar/blob/master/docs/installation.md
    hardware.logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };

    systemd.user.services.solaar = {
      description = "Solaar, the open source driver for Logitech devices";
      wantedBy = [ "graphical-session.target" ];
      after = [ "dbus.service" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe pkgs.solaar} --window hide";
        Restart = "on-failure";
        RestartSec = "5";
      };
    };
  };
}
