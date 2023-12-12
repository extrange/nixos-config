{ lib, pkgs, ... }:

{

  dconf.settings = with lib.hm.gvariant; {
    "org/gnome/desktop/interface" = {
      show-battery-percentage = true;
    };
  };

  home.file.".config/gtk-3.0/bookmarks" = {
    source = ./bookmarks;
    force = true;
  };

}
