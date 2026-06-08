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
  ddcutil = true;
  allowSsh = {
    enable = true;
    forRoot = true; # Chanel's btrbk-archive
  };
  ffmpegCustom = true;
  enablePrinting = true;
  fixLogiBoltSleep = true;

  users.users."${config.userName}".extraGroups = [
    "dialout" # For ESP32 programming
  ];

  # Boot drive encryption
  boot.initrd.luks.devices."luks-primary" = {
    device = "/dev/disk/by-label/primary";
    bypassWorkqueues = true; # https://nicholaslyz.com/blog/2025/05/14/dm-crypt-causing-system-freezes/
  };

  # Allow this host to redirect its USB devices to VMs
  virtualisation.spiceUSBRedirection.enable = true;

  home-manager.users.user = {
    home.packages = with pkgs; [
      clinfo # Check OpenCL
      darktable
      digikam
      nvtopPackages.amd
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

    # Set fractional scaling and monitor position
    home.file.".config/monitors.xml" = {
      source = ./monitors.xml;
      force = true; # overwrite existing
    };

  };

  # Upgrade once a week max
  system.autoUpgrade.dates = lib.mkForce "Sun *-*-* 05:00:00";
}
