{
  config,
  specialArgs,
  pkgs,
  lib,
  ...
}:
let
  # Common mount options for local drives
  mountOptions = [
    "nofail"
    "noatime"
    "nosuid"
    "nodev"
    "compress-force=zstd"
  ];
in
{
  allowSsh = {
    enable = true;
    forRoot = true; # For virt-manager/qemu kvm access
  };
  ffmpegCustom = true;
  wifi = {
    enable = false;
    interface-name = "wlp0s29u1u4i2";
  };
  uptime = {
    enable = true;
    url = "https://uptime.icybat.com/api/push/4RbFRv0UVQ?status=up&msg=OK&ping=";
  };

  # Shared folder
  # If a folder in /mnt is used it is owned by root
  fileSystems."/home/user/software" = {
    device = "/dev/disk/by-uuid/83eb9c35-b354-4a0e-9695-e994edeb11fa";
    fsType = "btrfs";
    options = [ "subvol=root" ] ++ mountOptions;
  };

  # Import our vm storage pool
  boot.zfs.extraPools = [ "vm-data" ];

  # VFIO Passthrough
  boot.initrd.kernelModules = [
    "vfio_pci"
    "vfio"
    "vfio_iommu_type1"
  ];
  boot.kernelParams = [
    "intel_iommu=on"
    "vfio-pci.ids=1002:7550,1002:ab40"
  ];

  home-manager.users.user = {

  };

  # VSCode Remote Server fix
  programs.nix-ld.enable = true;
}
