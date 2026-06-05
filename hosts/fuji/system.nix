{
  pkgs,
  config,
  lib,
  ...
}:
{

  buildRemote = true;
  graphical = true;
  allowSsh = {
    # TODO Temporary!!
    enable = true;
    forRoot = true;
  };
  zswap = true;
  enablePrinting = true;
  userName = "chanel";

  services.keyd.enable = lib.mkForce false;

  # For ddcutil (monitor brightness control)
  boot.kernelModules = [ "i2c-dev" ];
  services.udev.extraRules = ''
    SUBSYSTEM=="i2c-dev", KERNEL=="i2c-[0-9]*", ATTRS{class}=="0x030000", TAG+="uaccess"
    SUBSYSTEM=="dri", KERNEL=="card[0-9]*", TAG+="uaccess"
  '';

  virtualisation.spiceUSBRedirection.enable = true;

  environment.systemPackages = with pkgs; [
    ddcutil
  ];
}
