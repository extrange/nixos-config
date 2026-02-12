{
  lib,
  config,
  ...
}:
with lib;
{
  options.remoteDesktop = mkEnableOption "Unattended Remote Desktop via Gnome";
  config = mkIf config.remoteDesktop {

    services.gnome.gnome-remote-desktop.enable = true;
    systemd.services.gnome-remote-desktop = {
      wantedBy = [ "graphical.target" ]; # for starting the unit automatically at boot
    };
    services.displayManager.autoLogin.enable = lib.mkForce false;
    networking.firewall.allowedTCPPorts = [
      3389
      3390
    ];
    systemd.services.gnome-remote-desktop-configuration.serviceConfig.Environment = [
      "PATH=/run/wrappers/bin:/run/current-system/sw/bin"
      "SHELL=/run/current-system/sw/bin/bash"
    ];
  };
}
