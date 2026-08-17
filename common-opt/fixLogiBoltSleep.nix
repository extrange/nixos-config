{
  lib,
  config,
  ...
}:
with lib;
{
  options.fixLogiBoltSleep = mkEnableOption "Fixes for Logitech Bolt/Unifying receivers waking the PC from sleep";

  config = mkIf config.fixLogiBoltSleep {
    # Adds udev rules for solaar.
    # Note that you need to replug+repair the keyboard for the first time
    # https://github.com/3v1n0/Solaar/blob/master/docs/installation.md
    programs.solaar = {
      enable = true;
      userService.enable = true;
    };
  };
}
