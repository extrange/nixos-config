{ lib, ... }:

{

  dconf.settings = with lib.hm.gvariant; {
    "org/gnome/desktop/interface" = {
      show-battery-percentage = true;
    };
  };
}
