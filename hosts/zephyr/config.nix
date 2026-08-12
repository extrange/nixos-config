{
  config,
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
  uptime = {
    enable = true;
    url = "https://uptime.icybat.com/api/push/4RbFRv0UVQ?status=up&msg=OK&ping=";
  };
  zswap = true;

  # Fix name of ethernet adapter (for VM)
  systemd.network.links."10-lan" = {
    matchConfig = {
      MACAddress = "24:4b:fe:45:61:6a"; # most reliable for a physical NIC
    };
    linkConfig = {
      Name = "lan";
    };
  };

  # ZFS
  boot = {
    # With ZFS, we cannot use the latest kernel (linuxPackages_latest)
    kernelPackages = pkgs.linuxPackages;
    supportedFilesystems = [ "zfs" ];
    zfs = {
      forceImportRoot = false; # Recommended disabled
      extraPools = [
        "vm-data"
        "vm-os"
      ];
    };
  };
  services.zfs.autoScrub.enable = true;
}
