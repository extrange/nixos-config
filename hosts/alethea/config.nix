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

  services.btrfs.autoScrub.enable = lib.mkForce false; # We are using ext4

  # Enable moonlight streaming
  services.sunshine = {
    enable = true;
    autoStart = true; # optional: starts Sunshine automatically on login
    capSysAdmin = true;
    openFirewall = true;
  };
  services.displayManager.autoLogin.enable = lib.mkForce true; # Required for moonlight to work
  users.users.user.extraGroups = [ "uinput" ]; # fix cursor not moving
  environment.variables.MUTTER_DEBUG_DISABLE_HW_CURSORS = 1; # fix curson not showing

  home-manager.users.user = {

    home.packages = with pkgs; [
      gnomeExtensions.custom-hot-corners-extended
    ];

    dconf.settings = with home-manager.lib.hm.gvariant; {
      "org/gnome/mutter" = {
        # Fractional scaling
        experimental-features = [ "scale-monitor-framebuffer" ];
      };

      "org/gnome/shell/extensions/vitals" = {
        hot-sensors = [
          "_system_load_1m_"
          "_memory_usage_"
          "__network-rx_max__"
        ];
      };

      "org/gnome/shell/extensions/dash-to-dock" = {
        require-pressure-to-show = false;
      };

      "org/gnome/shell" = {
        enabled-extensions = [
          "custom-hot-corners-extended@G-dH.github.com"
        ];
      };

      "org/gnome/shell/extensions/custom-hot-corners-extended/monitor-0-top-left-0" = {
        action = "toggle-overview-app";
      };
      "org/gnome/shell/extensions/custom-hot-corners-extended/misc" = {
        barrier-fallback = true;
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
