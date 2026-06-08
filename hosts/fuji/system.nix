{
  pkgs,
  config,
  lib,
  ...
}:

let
  wifiInterface = "wlp0s20f3";
  user = config.userName;
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
  fixLogiBoltSleep = true;

  # Secure Boot
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  users = {
    mutableUsers = lib.mkForce true; # Allow using passwd
    users.${user}.hashedPasswordFile = lib.mkForce null;
  };
  services.keyd.enable = lib.mkForce false;
  virtualisation.spiceUSBRedirection.enable = true;
}
