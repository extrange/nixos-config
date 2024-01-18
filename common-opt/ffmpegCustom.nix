{ pkgs, lib, config, ... }:
with lib;
{
  options.ffmpegCustom = mkOption {
    type = types.bool;
    description = "Ffmpeg with FdkAac codec support";
    example = true;
    default = true;
  };

  config = {
    home-manager.users.user.home.packages = with pkgs; [
      (
        if config.ffmpegCustom then
          ffmpeg.override { withFdkAac = true; withUnfree = true; }
        else
          ffmpeg
      )
    ];
  };
}
