{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-WDC_PC_SN520_SDAPNUW-128G-1006_1903C4801837"; # 128GB NVME
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
                    swap.swapfile.size = "4G";
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
