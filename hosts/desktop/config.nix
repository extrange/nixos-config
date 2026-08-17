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
  remoteDesktop = true;

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

    dconf.settings =
      with home-manager.lib.hm.gvariant;
      let
        qemuUris = [ "qemu+ssh://root@zephyr/system" ];
      in
      {
        # Virt-manager connections
        "org/virt-manager/virt-manager/connections" = {
          uris = qemuUris;
        };
        "org/virt-manager/virt-manager/connections" = {
          autoconnect = qemuUris;
        };
        "org/gnome/mutter" = {
          # Fractional scaling
          experimental-features = [ "scale-monitor-framebuffer" ];
        };
        "org/gnome/desktop/session" = {
          idle-delay = mkUint32 900; # 15mins
        };

        "org/gnome/shell/extensions/vitals" = {
          hot-sensors = [
            "_processor_usage_"
            "_memory_usage_"
            "_temperature_processor_0_"
            "__network-rx_max__"
            "_temperature_amdgpu_edge_"
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
