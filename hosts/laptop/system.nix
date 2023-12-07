{ pkgs, lib, ... }:
{

  # TODO remove once partition sorted out
  boot.initrd.luks.devices."luks-primary".device = lib.mkForce "/dev/disk/by-uuid/229ba225-5c80-4f5e-a70d-03b616e63415";

  hardware.opengl.extraPackages = with pkgs; [
    intel-media-driver
    intel-compute-runtime
  ];
}
