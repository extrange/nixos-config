{ lib, pkgs, ... }:

{
  
  # For Davinci resolve
  home.sessionVariables = {
    ROC_ENABLE_PRE_VEGA = "1";
  };

  dconf.settings = with lib.hm.gvariant; {
    "org/gnome/mutter" = {
      # Fractional scaling
      experimental-features = [ "scale-monitor-framebuffer" ];
    };
    "org/gnome/desktop/session" = {
      # Don't dim screen
      idle-delay = mkUint32 0;
    };
    "org/gnome/settings-daemon/plugins/power" = {
      # Don't sleep
      sleep-inactive-ac-type = "nothing";
    };

    # QEMU config
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu+ssh://root@server/system" ];
      uris = [ "qemu+ssh://root@server/system" ];
    };
  };

  home.file = {
    # Set fractional scaling and monitor position
    ".config/monitors.xml" = {
      source = ./monitors.xml;
      force = true; # overwrite existing
    };
  };

  home.packages = with pkgs; [
    nvtop
    clinfo # Check OpenCL
  ];
}
