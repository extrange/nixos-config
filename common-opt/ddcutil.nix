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
        gnomeExtensions.brightness-control-using-ddcutil
      ];
      dconf.settings = {
        "org/gnome/shell/extensions/display-brightness-ddcutil" = {
          button-location = 1; # Show in system menu
          only-all-slider = true;
          show-all-slider = true;
          allow-zero-brightness = true;
          disable-display-state-check = true;
          show-value-label = true;
          hide-system-indicator = true;
          ddcutil-binary-path = "${pkgs.ddcutil}/bin/ddcutil";
          increase-brightness-shortcut = [ "MonBrightnessUp" ];
          decrease-brightness-shortcut = [ "MonBrightnessDown" ];
        };
        "org/gnome/shell" = {
          enabled-extensions = [
            "display-brightness-ddcutil@themightydeity.github.com"
          ];
        };
      };
    };
  };
}
