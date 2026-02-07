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
  zswap = true;

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.grub.configurationLimit = 3;

  home-manager.users.user = { };
}
