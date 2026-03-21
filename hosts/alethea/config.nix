{
  pkgs,
  lib,
  config,
  home-manager,
  ...
}:

{
  buildRemote = true;
  graphical = true;
  remoteDesktop = true;
  allowSsh = {
    enable = true;
    forRoot = true;
  };

  services.displayManager.autoLogin.enable = lib.mkForce false;
  services.btrfs.autoScrub.enable = lib.mkForce false; # We are using ext4

  home-manager.users.user = {

    home.packages = with pkgs; [
    ];

    dconf.settings = with home-manager.lib.hm.gvariant; {
      # Vitals
      "org/gnome/shell/extensions/vitals" = {
        hot-sensors = [
          "_system_load_1m_"
          "_memory_usage_"
          "__network-rx_max__"
        ];
      };

      # Don't dim screen
      "org/gnome/desktop/session" = {
        "idle-delay" = mkUint32 0;
      };

      "org/gnome/settings-daemon/plugins/power" = {
        # Don't sleep on AC power
        sleep-inactive-ac-type = "nothing";
      };
    };

  };
}
