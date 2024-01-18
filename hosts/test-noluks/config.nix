{ config, pkgs, home-manager, lib, ... }:
{
  imports = [ ./../test/config.nix ];

  # No disk encryption
  boot.initrd.luks.devices = lib.mkForce { };
}
