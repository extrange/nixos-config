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

  home-manager.users.user = { };
}
