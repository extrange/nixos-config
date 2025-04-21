{ config, lib, ... }:
with lib;
{
  options.wifi = {
    enable = mkEnableOption "wifi profiles";
    interface-name = mkOption {
      type = types.nonEmptyStr;
      description = "Wifi interface name";
      example = "wlp1s0";
      default = null;
    };
  };

  config = mkIf config.wifi.enable {

    sops.secrets = {
      wifi = { };
    };

    # Generate using https://github.com/janik-haag/nm2nix
    networking.networkmanager = {
      enable = true;
      ensureProfiles = {
        environmentFiles = [ config.sops.secrets.wifi.path ];
        profiles = {
          home-wifi = {
            connection = {
              id = "$home_wifi_ssid";
              type = "wifi";
              interface-name = config.wifi.interface-name;
            };
            wifi = {
              mode = "infrastructure";
              ssid = "$home_wifi_ssid";
            };
            wifi-security = {
              auth-alg = "open";
              key-mgmt = "wpa-psk";
              psk = "$home_wifi_psk";
            };
            ipv4 = {
              method = "auto";
            };
            ipv6 = {
              addr-gen-mode = "default";
              method = "auto";
            };
          };

          "Wireless@SGx" = {
            connection = {
              id = "Wireless@SGx";
              uuid = "0182a38c-8ad0-4c9e-a438-e631f591eedf";
              type = "wifi";
              interface-name = config.wifi.interface-name;
            };
            wifi = {
              mode = "infrastructure";
              ssid = "Wireless@SGx";
              security = "802-11-wireless-security";
            };
            wifi-security = {
              key-mgmt = "wpa-eap";
            };
            "802-1x" = {
              eap = "peap;";
              identity = "essa-MigsYlp4938@m1net.com.sg";
              password = "$wireless_sgx";
              phase2-auth = "mschapv2";
            };
            ipv4 = {
              method = "auto";
            };
            ipv6 = {
              addr-gen-mode = "stable-privacy";
              method = "auto";
            };
          };
        };
      };
    };
  };
}
