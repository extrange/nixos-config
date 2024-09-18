{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}:
{
  buildRemote = true;
  graphical = true;

  # For davinci resolve
  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr.icd
  ];

  # Allow compiling rpi4 iso
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # For ddcutil (monitor brightness control)
  boot.kernelModules = [ "i2c-dev" ];
  services.udev.extraRules = ''
    SUBSYSTEM=="i2c-dev", KERNEL=="i2c-[0-9]*", ATTRS{class}=="0x030000", TAG+="uaccess"
    SUBSYSTEM=="dri", KERNEL=="card[0-9]*", TAG+="uaccess"
  '';

  nix.settings.trusted-substituters = [ "https://raspberry-pi-nix.cachix.org" ];

  home-manager.users.user = {
    home.packages = with pkgs; [
      clinfo # Check OpenCL
      nvtopPackages.amd
      rpi-imager
      ddcutil

      davinci-resolve

      gnomeExtensions.brightness-control-using-ddcutil
    ];

    # For Davinci resolve
    home.sessionVariables = {
      ROC_ENABLE_PRE_VEGA = "1";
    };

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
      };

    };

    home.file = {
      # Set fractional scaling and monitor position
      ".config/monitors.xml" = {
        source = ./monitors.xml;
        force = true; # overwrite existing
      };
    };
  };

  # Upgrade once a week max
  system.autoUpgrade.dates = lib.mkForce "Sun *-*-* 05:00:00";
}
