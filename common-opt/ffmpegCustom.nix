{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
{
  options.ffmpegCustom = mkEnableOption "Ffmpeg with FdkAac codec support";

  config = {
    home-manager.users.user.home.packages = with pkgs; [
      (
        if config.ffmpegCustom then
          ffmpeg.override {
            withFdkAac = true;
            withUnfree = true;
          }
        else
          ffmpeg
      )
    ];
  };
}
