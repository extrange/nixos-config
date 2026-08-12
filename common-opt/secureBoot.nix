{ lib, config, ... }:
with lib;
{
  options.secureBoot = mkEnableOption "Secure Boot (via lanzaboote)";

  config = mkIf config.secureBoot {
    boot = {
      loader.systemd-boot.enable = mkForce false;
      lanzaboote = {
        configurationLimit = 8;
        enable = true;
        autoGenerateKeys.enable = true;
        autoEnrollKeys = {
          enable = true;
          autoReboot = true;
        };
        pkiBundle = "/var/lib/sbctl";
        measuredBoot = {
          enable = true;
          pcrs = [
            0
            4
            7
          ];
        };
      };
    };
  };
}
