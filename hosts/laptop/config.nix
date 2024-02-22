{ pkgs, lib, config, home-manager, ... }:

{
  graphical = true;
  wifi = {
    enable = true;
    interface-name = "wlp0s20f3";
  };

  # Allow TZ to be set automatically
  time.timeZone = lib.mkForce null;

  # Intel GPU
  hardware.opengl.extraPackages = with pkgs; [
    intel-media-driver
    intel-compute-runtime
  ];

  boot.kernelParams = [
    # "usbcore.quirks=2386:433b:bk" # Touchscreen
  ];

  home-manager.users.user = {

    home.packages = with pkgs; [
      gnome.gnome-power-manager
      powertop
    ];

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
