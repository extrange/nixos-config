{ config, ... }:
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-WDC_PC_SN720_SDAPNTW-512G-1014_190885806635";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "1024M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            luks = {
              size = "100%";
              name = "luks-fuji";
              content = {
                type = "luks";
                name = "cryptroot";
                settings = {
                  allowDiscards = true;
                  crypttabExtraOpts = [
                    "tpm2-device=auto"
                  ];
                  bypassWorkqueues = true; # https://nicholaslyz.com/blog/2025/05/14/dm-crypt-causing-system-freezes/
                };
                content = {
                  type = "btrfs";
                  subvolumes =
                    let
                      mountOptions = [
                        "noatime"
                        "compress"
                      ];
                    in
                    {
                      "/root" = {
                        mountpoint = "/";
                        inherit mountOptions;
                      };
                      "/home" = {
                        mountpoint = "/home";
                        inherit mountOptions;
                      };
                      "/swap" = {
                        mountpoint = "/swap";
                        swap.swapfile.size = "16G";
                      };
                    };
                };
              };
            };
          };
        };
      };
    };
  };
}
