{
  config,
  specialArgs,
  pkgs,
  lib,
  ...
}:
let
  pools = [
    "vm-data"
    "vm-os"
  ];
in
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

  # Import our vm storage pool
  boot.zfs.extraPools = pools;
  services.zfs.autoScrub = pools;

  # VFIO Passthrough
  boot.initrd.kernelModules = [
    "vfio_pci"
    "vfio"
    "vfio_iommu_type1"
  ];
  boot.kernelParams = [
    "intel_iommu=on"
  ];

  home-manager.users.user = { };

  # VSCode Remote Server fix
  programs.nix-ld.enable = true;
}
