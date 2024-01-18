{ pkgs, lib, config,... }:
with lib;
{
  options.ffmpegCustom = mkOption {
    type = types.bool;
    description = "Ffmpeg with FdkAac codec support";
    example = true;
    default = true;
  };

  config = mkIf config.ffmpegCustom {
    home-manager.users.user.home.packages = with pkgs; [
      (ffmpeg.override { withFdkAac = true; withUnfree = true; })
    ];
  };
}
