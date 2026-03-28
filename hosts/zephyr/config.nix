{
  config,
  specialArgs,
  pkgs,
  lib,
  ...
}:
{
  allowSsh = {
    enable = true;
    forRoot = true; # For virt-manager/qemu kvm access
  };
  uptime = {
    enable = true;
    url = "https://uptime.icybat.com/api/push/4RbFRv0UVQ?status=up&msg=OK&ping=";
  };
  zswap = true;

  # Disable TSO to fix hanging on the e1000e NIC
  # https://forum.proxmox.com/threads/e1000e-eno1-detected-hardware-unit-hang.59928/page-5#post-805080
  networking.networkmanager.ensureProfiles.profiles = {
    "Wired Connection 1" = {
      connection = {
        id = "Wired Connection 1";
        interface-name = "eno1";
        type = "ethernet";
      };
      ethtool = {
        "feature-tso" = false;
      };
    };

  };

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

  # VFIO Passthrough
  boot.kernelModules = [
    "vfio_pci"
    "vfio"
    "vfio_iommu_type1"
  ];
  boot.kernelParams = [
    "intel_iommu=on"
  ];

  home-manager.users.user = { };
}
