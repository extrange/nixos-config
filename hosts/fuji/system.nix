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

  services.keyd.enable = lib.mkForce false;
  virtualisation.spiceUSBRedirection.enable = true;
}
