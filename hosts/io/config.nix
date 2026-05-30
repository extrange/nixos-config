{
  config,
  specialArgs,
  pkgs,
  lib,
  ...
}:
{
  allowSsh.enable = true;
  zswap = true;

  # The VPS doesn't support UEFI
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.grub.configurationLimit = 3;

  home-manager.users.user = { };
}
