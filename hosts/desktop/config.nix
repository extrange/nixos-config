{ config, pkgs, lib, home-manager, ... }:
{
  graphical = true;

  # For davinci resolve
  hardware.opengl.extraPackages = with pkgs; [
    rocmPackages.clr.icd
  ];

  home-manager.users.user = {
    home.packages = with pkgs; [
      clinfo # Check OpenCL
      davinci-resolve # TODO fix URL malformed error with overlays
      nvtop
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

      # QEMU config
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = [ "qemu+ssh://root@server/system" ];
        uris = [ "qemu+ssh://root@server/system" ];
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
  # Allow at most cores * threads processes to run
  nix.settings.cores = 4;
  nix.settings.max-jobs = 2;

}
 