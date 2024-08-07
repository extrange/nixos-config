{ config, pkgs, lib, home-manager, ... }:
{
  buildRemote = true;
  graphical = true;

  # For davinci resolve
  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr.icd
  ];

  # Allow compiling rpi4 iso
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  nix.settings.trusted-substituters = [ "https://raspberry-pi-nix.cachix.org" ];

  home-manager.users.user = {
    home.packages = with pkgs; [
      clinfo # Check OpenCL
      davinci-resolve
      nvtopPackages.amd
      rpi-imager
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

      # Vitals
      "org/gnome/shell/extensions/vitals" = {
        hot-sensors = [
          "_system_load_1m_"
          "_memory_usage_"
          "_temperature_processor_0_"
          "_temperature_amdgpu_edge_"
          "__network-rx_max__"
        ];
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
 