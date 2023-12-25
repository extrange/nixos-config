{ lib, pkgs, ... }:

{

  dconf.settings = with lib.hm.gvariant; {
    "org/gnome/desktop/interface" = {
      show-battery-percentage = true;
    };
    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
    };
  };

}
