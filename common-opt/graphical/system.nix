# Packages and options for graphical systems
{ config, pkgs, lib, self, hostname, ... }:
with lib;
{
  config = mkIf config.graphical {

    # Display
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    # Display: enable automatic login for the user.
    services.displayManager.autoLogin.enable = true;
    services.displayManager.autoLogin.user = "user";
    # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
    systemd.services."getty@tty1".enable = lib.mkForce false;
    systemd.services."autovt@tty1".enable = lib.mkForce false;

    # Fix login keyring
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.sddm.enableGnomeKeyring = true;

    environment.gnome.excludePackages = with pkgs.gnome; [
      epiphany # browser
      geary # mail reader
      gnome-shell-extensions # This seems to remove default extensions
      pkgs.gnome-tour
      totem # video player
    ];


    # Sound
    sound.enable = true;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Add SSHFS mounts for server
    fileSystems =
      let
        options = {
          options = [
            "noauto"
            "noatime"
            "user"
            "_netdev"
            "allow_other"
            "reconnect" # handle connection drops
            "ServerAliveInterval=15" # keep connections alive

            # Fixes sshfs not mounting automatically at boot
            "x-systemd.automount"

          ];
          fsType = "fuse.sshfs";
          noCheck = true; # Disable fsck
        };
      in
      {
        "/mnt/storage" = {
          device = "ssh.nicholaslyz.com:/mnt/storage";
        } // options;

        "/mnt/workspace" = {
          device = "ssh.nicholaslyz.com:/home/user";
        } // options;
      };

    services.btrfs.autoScrub.enable = true;

    environment.systemPackages = with pkgs; [
      sshfs # Can't be in user
    ];

    # Docs: https://github.com/rvaiya/keyd/blob/master/docs/keyd.scdoc
    services.keyd = {
      enable = true;
      keyboards = {
        default = {
          ids = [ "*" ];
          settings = {
            # This is a special layer name
            control = {
              # These changes also apply to control + shift
              # Meaning of z = "C-/": z (when Ctrl is pressed) is mapped to Control + /
              z = "C-/";
              x = "C-b";
              c = "C-i";
              v = "C-.";
              t = "C-k";
              w = "C-,";
            };
          };
        };
      };
    };
  };
}
