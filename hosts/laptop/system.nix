{ pkgs, lib, config, ... }:

{
  graphical = true;

  hardware.opengl.extraPackages = with pkgs; [
    intel-media-driver
    intel-compute-runtime
  ];

}
