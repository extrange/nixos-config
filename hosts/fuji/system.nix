{
  pkgs,
  config,
  lib,
  ...
}:

let
  wifiInterface = "wlp0s20f3";
in
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
  wifi = {
    enable = true;
    interface-name = wifiInterface;
  };

  # Secure Boot
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  services.keyd.enable = lib.mkForce false;
  virtualisation.spiceUSBRedirection.enable = true;
}
