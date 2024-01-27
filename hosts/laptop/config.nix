{ pkgs, lib, config, home-manager, ... }:

{
  graphical = true;
  wifi = {
    enable = true;
    interface-name = "wlp1s0";
  };

  # Allow TZ to be set automatically
  time.timeZone = lib.mkForce null;

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

      # Auto TZ
      "org/gnome/desktop/datetime" = { automatic-timezone = true; };
      "org/gnome/system/location" = { enabled = true; };
    };
  };
}
