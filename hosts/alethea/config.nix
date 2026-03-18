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

  home-manager.users.user = {

    home.packages = with pkgs; [
    ];

    dconf.settings = with home-manager.lib.hm.gvariant; {
      "org/gnome/desktop/interface" = {
        show-battery-percentage = true;
      };
      "org/gnome/desktop/peripherals/touchpad" = {
        tap-to-click = true;
        natural-scroll = false;
      };

      # Vitals
      "org/gnome/shell/extensions/vitals" = {
        hot-sensors = [
          "_system_load_1m_"
          "_memory_usage_"
          "_memory_swap_usage_"
          "__temperature_max__"
          "__network-rx_max__"
          "_battery_rate_"
          "_battery_time_left_"
        ];
        show-battery = true;
      };

      # Increase screen blank timeout (seconds)
      "org/gnome/desktop/session" = {
        "idle-delay" = mkUint32 900; # 15mins
      };

      "org/gnome/settings-daemon/plugins/power" = {
        # Don't sleep on AC power
        sleep-inactive-ac-type = "nothing";
      };
    };

  };
}
