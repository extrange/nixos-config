{
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
            luks = {
              size = "100%";
              name = "luks-zephyr";
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
                        "compress-force=zstd"
                      ];
                    in
                    {
                      "/root" = {
                        mountpoint = "/";
                        inherit mountOptions;
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

  };
}
