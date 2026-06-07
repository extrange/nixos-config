{
  pkgs,
  config,
  lib,
  ...
}:
{

  buildRemote = true;
  graphical = true;
  ddcutil = true;
  allowSsh = {
    # TODO Temporary!!
    enable = true;
    forRoot = true;
  };
  zswap = true;
  enablePrinting = true;
  userName = "chanel";

  services.keyd.enable = lib.mkForce false;

  virtualisation.spiceUSBRedirection.enable = true;
}
