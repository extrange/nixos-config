{ config, pkgs, lib, ... }:
{
  imports = [ ../../graphical/system.nix ];

  # For davinci resolve
  hardware.opengl.extraPackages = with pkgs; [
    rocmPackages.clr.icd
  ];

}
