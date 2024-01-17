{ pkgs, lib, config, home-manager, ... }:

{
  graphical = true;
  wifi = {
    enable = true;
    interface-name = "wlp1s0";
  };

  hardware.opengl.extraPackages = with pkgs; [
    intel-media-driver
    intel-compute-runtime
  ];

  home-manager.users.user = {
    dconf.settings = with home-manager.lib.hm.gvariant; {
      "org/gnome/desktop/interface" = {
        show-battery-percentage = true;
      };
      "org/gnome/desktop/peripherals/touchpad" = {
        tap-to-click = true;
      };
    };
  };
}
