{ config, pkgs, lib, ... }:
{

  # For davinci resolve
  hardware.opengl.extraPackages = with pkgs; [
    rocmPackages.clr.icd
  ];
}
