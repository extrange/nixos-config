{ pkgs, lib, config, home-manager, ... }:

{
  buildRemote = true;
  graphical = true;
  wifi = {
    enable = true;
    interface-name = "wlp0s20f3";
  };

  # Allow TZ to be set automatically
  time.timeZone = lib.mkForce null;

  # Intel GPU
  hardware.opengl.extraPackages = with pkgs; [
    intel-media-driver
    intel-compute-runtime
  ];

  # Increase zram to 100% of RAM
  zramSwap.memoryPercent = 100;

  boot.kernelParams = [
    # Fixes issue with laptop not sleeping
    # Note: flashing red light appears with deep, not with s2idle
    # Check type of sleep with cat /sys/power/mem_sleep
    #
    # If issue still persists, consider patching kernel to show s2idle wakeup reasons:
    # https://web.archive.org/web/20230614200306/https://01.org/blogs/qwang59/2020/linux-s0ix-troubleshooting
    "mem_sleep_default=deep"

    # Touchscreen: Disabled, as not required for now
    # "usbcore.quirks=2386:433b:bk"
  ];

  environment.variables = {
    AWS_PROFILE = "default";
  };

  home-manager.users.user = {

    home.packages = with pkgs; [
      gnome.gnome-power-manager
      powertop
    ];

    dconf.settings = with home-manager.lib.hm.gvariant; {
      "org/gnome/desktop/interface" = {
        show-battery-percentage = true;
      };
      "org/gnome/desktop/peripherals/touchpad" = {
        tap-to-click = true;
        natural-scroll = false;
      };

      # Auto TZ
      "org/gnome/desktop/datetime" = { automatic-timezone = true; };
      "org/gnome/system/location" = { enabled = true; };

      # Vitals
      "org/gnome/shell/extensions/vitals" = {
        hot-sensors = [
          "_system_load_1m_"
          "_memory_usage_"
          "__temperature_max__"
          "__network-rx_max__"
          "_battery_rate_"
          "_battery_time_left_"
        ];
      };

      # Increase screen blank timeout (seconds)
      "org/gnome/desktop/session" = {
        "idle-delay" = mkUint32 900; # 15mins
      };
    };

  };

  # Upgrade once a week max
  system.autoUpgrade.dates = lib.mkForce "Sun *-*-* 05:00:00";
}
