{
  config,
  lib,
  ...
}:
with lib;
{
  options.zswap = mkEnableOption "zswap";
  config = mkIf config.zswap {
    boot.initrd.kernelModules = [
      "zsmalloc" # For zswap
    ];
    boot.kernelParams = [
      # zswap
      "zswap.enabled=1"
      "zswap.compressor=zstd"
      "zswap.zpool=zsmalloc"
      "zswap.max_pool_percent=50"
      "zswap.shrinker_enabled=1"
    ];
  };
}
