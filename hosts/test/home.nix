{ lib, ... }:
{

  dconf.settings = with lib.hm.gvariant; {
    "org/gnome/desktop/session" = {
      # Don't dim screen
      idle-delay = mkUint32 0;
    };
    "org/gnome/desktop/input-sources" = {
      # Disable remap capslock to backspace
      xkb-options = [ ];
      # Set US keyboard layout
      sources = [ (mkTuple [ "xkb" "us" ]) ];
    };
  };

  home.file = {
    # SSHFS shortcuts
    ".config/gtk-3.0/bookmarks" = {
      source = ./bookmarks;
      force = true;
    };

    # Set fractional scaling and monitor position
    ".config/monitors.xml" = {
      source = ./monitors.xml;
      force = true; # overwrite existing
    };
  };
}
