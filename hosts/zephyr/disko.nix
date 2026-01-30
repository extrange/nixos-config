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
                      "compress=zstd"
                    ];
                    mountpoint = "/";
                  };
                };
                mountpoint = "/mnt/system-root";
              };
              swap.swapfile.size = "8G";
            };
          };
        };
      };
    };
    vm = {
      type = "disk";

      device = "/dev/disk/by-id/nvme-ADATA_SX6000LNP_2N2929Q682FG"; # 512GB NVME
      content = {
        type = "gpt";
        partitions = {
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              subvolumes = {
                "/root" = {
                  mountOptions = [
                    "noatime"
                  ];
                  mountpoint = "/mnt/vm";
                };
              };
              mountpoint = "/mnt/vm-root";
            };
          };
        };
      };
    };
  };
}
