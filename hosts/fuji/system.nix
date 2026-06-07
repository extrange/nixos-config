{
  pkgs,
  config,
  lib,
  ...
}:
{
  graphical = true;
  ddcutil = true;
  allowSsh = {
    enable = true;
    forRoot = true;
  };
  zswap = true;
  enablePrinting = true;
  userName = "chanel";

  # Encrypted boot
  boot.initrd.systemd.enable = true;
  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-partlabel/luks-fuji";
    bypassWorkqueues = true; # https://nicholaslyz.com/blog/2025/05/14/dm-crypt-causing-system-freezes/
  };

  services.keyd.enable = lib.mkForce false;

  virtualisation.spiceUSBRedirection.enable = true;
}
