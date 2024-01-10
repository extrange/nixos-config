{ config, specialArgs, pkgs, lib, ... }:
{
  imports = [ ../../graphical/system.nix ];
  services.keyd.enable = lib.mkForce false;
}
