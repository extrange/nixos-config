{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  user = config.userName;
in
{
  options.ddcutil = mkEnableOption "Monitor brightness control via DDC/CI (requires compatible display)";

  config = mkIf config.ddcutil {
    boot.kernelModules = [ "i2c-dev" ];
    services.udev.extraRules = ''
      SUBSYSTEM=="i2c-dev", KERNEL=="i2c-[0-9]*", ATTRS{class}=="0x030000", TAG+="uaccess"
      SUBSYSTEM=="dri", KERNEL=="card[0-9]*", TAG+="uaccess"
    '';
    environment.systemPackages = with pkgs; [ ddcutil ];
    hardware.i2c.enable = true;

    home-manager.users."${user}" = {
      home.packages = with pkgs; [
        gnomeExtensions.ddc-brightness-controller
      ];
      dconf.settings = {
        "org/gnome/shell/extensions/ddcbrightness" = {
          vcp-code = "10";
          step = 10;
          link-displays = false; # single monitor
          brightness-up = [ "XF86MonBrightnessUp" ];
          brightness-down = [ "XF86MonBrightnessDown" ];
        };
        "org/gnome/shell" = {
          enabled-extensions = [
            "ddcbrightness@lucaso.io"
          ];
        };
      };
    };
  };
}
