# TODO: Stub file to prevent btrfs autoscrub errors when no filesystem is specified.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "virtio_pci"
    "virtio_scsi"
    "sr_mod"
    "virtio_blk"
  ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/3629c236-54b6-43ed-a4f0-6d471ba9f9fa";
    fsType = "btrfs";
    options = [ "subvol=root" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/B9E2-9387";
    fsType = "vfat";
  };

  swapDevices = [ ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = true;
}
