{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}:
{
  imports = [ ./brightness.nix ];
  graphical = true;
  addAuthorizedKeys = {
    enable = true;
    forRoot = true; # Chanel's btrbk-archive
  };
  ffmpegCustom = true;

  # Boot drive encryption
  boot.initrd.luks.devices."luks-primary" = {
    device = "/dev/disk/by-label/primary";
    bypassWorkqueues = true; # https://nicholaslyz.com/blog/2025/05/14/dm-crypt-causing-system-freezes/
  };

  # Adds udev rules for solaar.
  # Note that you need to replug+repair the keyboard for the first time
  # https://github.com/3v1n0/Solaar/blob/master/docs/installation.md
  hardware.logitech.wireless = {
    enable = true;
    enableGraphical = true;
  };

  # Printer
  services.printing.enable = true;
  hardware.printers =
    let
      brother = "Brother_MFC-J470DW";
    in
    {
      ensurePrinters = [
        {
          name = brother;
          location = "Home";
          deviceUri = "ipp://192.168.1.101/ipp";
          model = "everywhere";
        }
      ];
      ensureDefaultPrinter = brother;

    };

  # For ddcutil (monitor brightness control)
  boot.kernelModules = [ "i2c-dev" ];
  services.udev.extraRules = ''
    SUBSYSTEM=="i2c-dev", KERNEL=="i2c-[0-9]*", ATTRS{class}=="0x030000", TAG+="uaccess"
    SUBSYSTEM=="dri", KERNEL=="card[0-9]*", TAG+="uaccess"
  '';

  # Archival drives
  fileSystems."/mnt/chanel-archive" = {
    device = "/dev/disk/by-uuid/803c34f4-a16a-4c9f-abf2-f734157d08e8";
    options = [
      "noauto"
      "compress-force=zstd"
      "x-systemd.automount" # Automatically mount on access
      "x-systemd.device-timeout=1s" # Don't freeze when accessing directory without the device
    ];
  };

  home-manager.users.user = {
    home.packages = with pkgs; [
      clinfo # Check OpenCL
      darktable
      ddcutil
      digikam
      nvtopPackages.amd
      solaar

      gnomeExtensions.brightness-control-using-ddcutil
      gnomeExtensions.solaar-extension
    ];

    dconf.settings = with home-manager.lib.hm.gvariant; {
      "org/gnome/mutter" = {
        # Fractional scaling
        experimental-features = [ "scale-monitor-framebuffer" ];
      };
      "org/gnome/desktop/session" = {
        # Don't dim screen
        idle-delay = mkUint32 0;
      };
      "org/gnome/settings-daemon/plugins/power" = {
        # Don't sleep
        sleep-inactive-ac-type = "nothing";
      };

      "org/gnome/shell" = {
        enabled-extensions = [
          "display-brightness-ddcutil@themightydeity.github.com"
        ];
      };

      "org/gnome/shell/extensions/vitals" = {
        hot-sensors = [
          "_system_load_1m_"
          "_memory_usage_"
          "_temperature_processor_0_"
          "_temperature_amdgpu_edge_"
          "__network-rx_max__"
        ];
      };

      "org/gnome/shell/extensions/display-brightness-ddcutil" = {
        button-location = 1; # Show in system menu
        only-all-slider = true;
        show-all-slider = true;
        allow-zero-brightness = true;
        disable-display-state-check = true; # Seems to make changes faster
        show-value-label = true;
        hide-system-indicator = true;
        ddcutil-binary-path = "${pkgs.ddcutil}/bin/ddcutil";
        increase-brightness-shortcut = [ "MonBrightnessUp" ];
        decrease-brightness-shortcut = [ "MonBrightnessDown" ];
      };

    };

    # Set fractional scaling and monitor position
    home.file.".config/monitors.xml" = {
      source = ./monitors.xml;
      force = true; # overwrite existing
    };

    # Fixes Logitech Bolt receiver (kb) waking immediately after sleep
    home.file.".config/autostart/solaar.desktop" = {
      text = ''
        [Desktop Entry]
        Type=Application
        Name=Solaar
        Exec=${pkgs.solaar}/bin/solaar -w hide
      '';
      force = true;
    };

  };

  # Upgrade once a week max
  system.autoUpgrade.dates = lib.mkForce "Sun *-*-* 05:00:00";
}
