{
  pkgs,
  lib,
  config,
  home-manager,
  ...
}:

{
  buildRemote = true;
  ffmpegCustom = true;
  graphical = true;
  wifi = {
    enable = true;
    interface-name = "wlp0s20f3";
  };
  zram = {
    enable = true;
    memoryPercent = 200; # This laptop only has 8GB of RAM so we need even more ZRAM
  };

  # Boot drive encryption
  boot.initrd.luks.devices."luks-primary" = {
    device = "/dev/disk/by-label/primary";
    bypassWorkqueues = true; # https://nicholaslyz.com/blog/2025/05/14/dm-crypt-causing-system-freezes/
  };

  # Declare secret and fix its permissions
  sops.secrets."laptop/syncthing/key".owner = config.users.users.user.name;

  # Intel GPU
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    intel-compute-runtime
  ];

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

  home-manager.users.user = {

    home.packages = with pkgs; [
      gnome-power-manager
      powertop
    ];

    services.syncthing = {
      enable = true;
      cert = "${./syncthing-cert.pem}";
      key = config.sops.secrets."laptop/syncthing/key".path;
      settings = {
        devices = {
          server.id = "VE43VRC-5MUVL3A-CDIUUQI-3P5VTUZ-Y2YVRTY-HRIJN2U-5JAKLHC-XOYZCAX";
        };
        folders = {
          Notes = {
            path = "~/Notes";
            id = "ottug-sdies";
            devices = [ "server" ];
          };
          "Passport and ID Photos" = {
            path = "~/Passport and ID Photos";
            id = "afha9-5cpt3";
            devices = [ "server" ];
          };
          Relationship = {
            path = "~/Relationship";
            id = "dvz3s-wetzy";
            devices = [ "server" ];
          };
        };
      };
    };

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
    };

  };

  # Upgrade once a week max
  system.autoUpgrade.dates = lib.mkForce "Sun *-*-* 05:00:00";

  # Don't upgrade on battery
  systemd.services.nixos-upgrade = {
    unitConfig = {
      ConditionACPower = true;
    };
  };
}
