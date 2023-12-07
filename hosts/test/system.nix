{ config, specialArgs, pkgs, lib, ... }:
{
  services.keyd.enable = lib.mkForce false;
}
