{ config, lib, ... }:
with lib;
{
  options.zram = {
    enable = mkEnableOption "zram. Note: zswap is preferred if there is swap space available (see https://linuxblog.io/zswap-better-than-zram/)";
    memoryPercent = mkOption {
      default = 50;
      description = "Maximum total amount of memory that can be stored in the zram swap devices (as a percentage of your total memory).";
      type = types.int;
    };
  };

  config =
    let
      cfg = config.zram;
    in
    mkIf cfg.enable {

      zramSwap = {
        enable = true;
        memoryPercent = cfg.memoryPercent;
      };

      # Optimize swap on zram
      # https://wiki.archlinux.org/title/Zram#Optimizing_swap_on_zram
      boot.kernel.sysctl = {
        "vm.swappiness" = 180;
        "vm.watermark_boost_factor" = 0;
        "vm.watermark_scale_factor" = 125;
        "vm.page-cluster" = 0;
      };
    };
}
