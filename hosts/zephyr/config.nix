{
  config,
  specialArgs,
  pkgs,
  lib,
  home-manager,
  ...
}:
{
  allowSsh = {
    enable = true;
    forRoot = true; # For virt-manager/qemu kvm access
  };
  ffmpegCustom = true;
  enablePrinting = true;
  fixLogiBoltSleep = true;
  graphical = true;
  ddcutil = true;
  remoteDesktop = true;
  uptime = {
    enable = true;
    url = "https://uptime.icybat.com/api/push/4RbFRv0UVQ?status=up&msg=OK&ping=";
  };
  zswap = true;

  # Secure Boot
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    configurationLimit = 8;
    enable = true;
    autoGenerateKeys.enable = true;
    autoEnrollKeys = {
      enable = true;
      autoReboot = true;
    };
    pkiBundle = "/var/lib/sbctl";
    measuredBoot = {
      enable = true;
      pcrs = [
        0
        4
        7
      ];
    };

  };

  users.users."${config.userName}".extraGroups = [
    "dialout" # For ESP32 programming
  ];

  # ZFS
  boot = {
    # With ZFS, we cannot use the latest kernel (linuxPackages_latest)
    kernelPackages = pkgs.linuxPackages;
    supportedFilesystems = [ "zfs" ];
    zfs.forceImportRoot = false; # Recommended disabled
  };
  boot.zfs.extraPools = [
    "vm-data"
    "vm-os"
  ];
  services.zfs.autoScrub.enable = true;

  # Libvirt
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemu.swtpm.enable = true;

  # Allow this host to redirect its USB devices to VMs
  virtualisation.spiceUSBRedirection.enable = true;

  # VFIO Passthrough
  boot.kernelModules = [
    "vfio_pci"
    "vfio"
    "vfio_iommu_type1"
  ];
  boot.kernelParams = [
    "intel_iommu=on"
    "vfio-pci.ids=10de:2705,10de:22bb" # Nvidia GPU
  ];

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

  };

}
