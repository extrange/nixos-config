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
  wifi = {
    enable = true;
    interface-name = "wlp0s20f3";
  };

  # Fix OOM errors
  zramSwap.memoryPercent = lib.mkForce 200;

  # Declare secret and fix its permissions
  sops.secrets."laptop/syncthing/key".owner = config.users.users.user.name;

  # Allow TZ to be set automatically
  time.timeZone = lib.mkForce null;

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

  environment.variables = {
    AWS_PROFILE = "default";
  };

  home-manager.users.user = {

    home.packages = with pkgs; [
      gnome-power-manager
      powertop
    ];

    services.syncthing = {
      enable = true;
      cert = "${pkgs.writeText "cert" ''
        -----BEGIN CERTIFICATE-----
        MIICGzCCAaKgAwIBAgIIdrD47i4ss54wCgYIKoZIzj0EAwIwSjESMBAGA1UEChMJ
        U3luY3RoaW5nMSAwHgYDVQQLExdBdXRvbWF0aWNhbGx5IEdlbmVyYXRlZDESMBAG
        A1UEAxMJc3luY3RoaW5nMB4XDTI0MDUwNTAwMDAwMFoXDTQ0MDQzMDAwMDAwMFow
        SjESMBAGA1UEChMJU3luY3RoaW5nMSAwHgYDVQQLExdBdXRvbWF0aWNhbGx5IEdl
        bmVyYXRlZDESMBAGA1UEAxMJc3luY3RoaW5nMHYwEAYHKoZIzj0CAQYFK4EEACID
        YgAE/f3CD/18TSBPNFH4JHp5F9SFfiFWS4UpmA6uOmkLTS4x8uxFFwMoUxYLIxyw
        YVjOLUnIqkhtYLys5gE1HU/ukqXnSeC6YOeXfExvcsG65DvnD5vzIQWCmdHXU8lx
        TbX5o1UwUzAOBgNVHQ8BAf8EBAMCBaAwHQYDVR0lBBYwFAYIKwYBBQUHAwEGCCsG
        AQUFBwMCMAwGA1UdEwEB/wQCMAAwFAYDVR0RBA0wC4IJc3luY3RoaW5nMAoGCCqG
        SM49BAMCA2cAMGQCMF6C3Q7S1ssOEEqEEkaWHf2jHhmmBHMw63t6Wrv0/g5rVkra
        LGVLE+oCZGNu7WEj6QIwUfaaSF4fuF4dKDn+t0+Oofd3ypu5UvYjFW5hxrA/7Qiy
        U+BJT91WkS68WvFv1w96
        -----END CERTIFICATE-----
      ''}";
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

      # Auto TZ
      "org/gnome/desktop/datetime" = {
        automatic-timezone = true;
      };
      "org/gnome/system/location" = {
        enabled = true;
      };

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
