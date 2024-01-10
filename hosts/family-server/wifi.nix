# Import this to enable wifi temporarily
{ config, ... }: {
  boot.extraModulePackages = with config.boot.kernelPackages; [
    rtl8821cu
  ];

  sops.secrets = {
    wifi = { };
  };

  networking.networkmanager.ensureProfiles = {
    environmentFiles = [ config.sops.secrets.wifi.path ];
    profiles = {
      home-wifi = {
        connection = {
          id = "home-wifi";
          type = "wifi";
          interface-name = "wlp0s29u1u4i2";
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
    };
  };
}
