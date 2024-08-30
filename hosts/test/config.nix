{
  config,
  pkgs,
  home-manager,
  lib,
  ...
}:
{
  graphical = true;
  services.keyd.enable = lib.mkForce false;
  ffmpegCustom = false;

  home-manager.users.user = {
    dconf.settings = with home-manager.lib.hm.gvariant; {
      "org/gnome/desktop/session" = {
        # Don't dim screen
        idle-delay = mkUint32 0;
      };
      "org/gnome/desktop/input-sources" = {
        # Disable remap capslock to backspace
        xkb-options = [ ];
        # Set US keyboard layout
        sources = [
          (mkTuple [
            "xkb"
            "us"
          ])
        ];
      };
    };

    home.file = {
      # Set fractional scaling and monitor position
      ".config/monitors.xml" = {
        source = ./monitors.xml;
        force = true; # overwrite existing
      };
    };
  };
}
