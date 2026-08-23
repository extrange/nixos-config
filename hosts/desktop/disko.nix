{ hostname, ... }: {
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-SAMSUNG_MZVLB512HBJQ-00000_S4GENX0N733466"; # 512GB NVME
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
              name = hostname;
              content = {
                type = "btrfs";
                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "noatime"
                      "compress-force=zstd"
                    ];
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
