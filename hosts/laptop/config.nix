{ pkgs, lib, config, home-manager, ... }:

{
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

  boot.kernelParams = [
    # "usbcore.quirks=2386:433b:bk" # Touchscreen
  ];

  # Swap fn behavior on mediakeys
  services.keyd.keyboards.default.settings = {
    main = {
      sleep = "f1";
      brightnessdown = "f3";
      brightnessup = "f4";

      f1 = "sleep";
      f3 = "brightnessdown";
      f4 = "brightnessup";
    };
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
    };

  };

    # Upgrade once a week max
    system.autoUpgrade.dates = lib.mkForce "Sun *-*-* 05:00:00";
    # Allow at most cores * threads processes to run
    nix.settings.cores = 2;
    nix.settings.max-jobs = 2;
}
