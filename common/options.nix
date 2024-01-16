# All possible options are defined here
{ lib, config, ... }:
with lib;
# assert config.wifi.enable -> config.wifi.interface-name != null;
{

  options.graphical = mkEnableOption "Graphical applications and utilities";

  options.wifi = {
    enable = mkEnableOption "wifi profiles";
    interface-name = mkOption {
      type = types.nonEmptyStr;
      description = "Wifi interface name";
      example = "wlp1s0";
      default = null;
    };
  };

}
