{ pkgs, lib, config, ... }:

{
  graphical = true;
  wifi = {
    enable = true;
    interface-name = "wlp1s0";
  };

  hardware.opengl.extraPackages = with pkgs; [
    intel-media-driver
    intel-compute-runtime
  ];

}
