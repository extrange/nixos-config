{
  lib,
  config,
  home-manager,
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
    networking.firewall.allowedTCPPorts = [
      3389
      3390
    ];
    systemd.services.gnome-remote-desktop-configuration.serviceConfig.Environment = [
      "PATH=/run/wrappers/bin:/run/current-system/sw/bin"
      "SHELL=/run/current-system/sw/bin/bash"
    ];

    # Disable screen blanking/sleep
    home-manager.users."${config.userName}".dconf.settings = with home-manager.lib.hm.gvariant; {
      "org/gnome/settings-daemon/plugins/power" = {
        sleep-inactive-ac-type = "nothing";
      };
    };
  };
}
