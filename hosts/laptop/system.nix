{ pkgs, lib, config, ... }:

{

  hardware.opengl.extraPackages = with pkgs; [
    intel-media-driver
    intel-compute-runtime
  ];

  sops.secrets = {
    wifi = { };
  };

  # Generate using https://github.com/janik-haag/nm2nix
  networking.networkmanager.ensureProfiles = {
    environmentFiles = [ config.sops.secrets.wifi.path ];
    profiles = {
      "Wireless@SGx" = {
        connection = {
          id = "Wireless@SGx";
          uuid = "0182a38c-8ad0-4c9e-a438-e631f591eedf";
          type = "wifi";
          interface-name = "wlp1s0";
        };
        wifi = {
          mode = "infrastructure";
          ssid = "Wireless@SGx";
        };
        wifi-security = {
          auth-alg = "open";
          key-mgmt = "wpa-eap";
        };
        "802-1x" = {
          eap = "peap;";
          identity = "essa-2eOQO0KdD0Hvl7vs8w-X-lk@singtel-wsg";
          password = "$wireless_sgx";
          phase2-auth = "mschapv2";
        };
        ipv4 = {
          method = "auto";
        };
        ipv6 = {
          addr-gen-mode = "default";
          method = "auto";
        };
        proxy = { };
      };
    };
  };

}
