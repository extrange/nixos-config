{ config, ... }:
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        name = builtins.substring 0 10 (builtins.hashString "sha256" config.disko.devices.disk.main.device);
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
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                subvolumes = {
                  "/root" = {
                    mountOptions = [
                      "noatime"
                      "compress-force=zstd"
                    ];
                    mountpoint = "/";
                  };
                  "/swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "16G";
                  };
                };
                mountpoint = "/mnt/system-root";
              };
            };
          };
        };
      };
    };

  };
}
