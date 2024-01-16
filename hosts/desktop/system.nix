{ config, pkgs, lib, ... }:
{
  graphical = true;

  # For davinci resolve
  hardware.opengl.extraPackages = with pkgs; [
    rocmPackages.clr.icd
  ];

}
 