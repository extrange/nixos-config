# Packages and options for graphical systems
{
  config,
  pkgs,
  lib,
  self,
  hostname,
  ...
}:
with lib;
{
  config = mkIf config.graphical {

    # Display
    services.xserver.enable = true;
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    # Display: enable automatic login for the user.
    services.displayManager.autoLogin.enable = true;
    services.displayManager.autoLogin.user = "user";
    # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
    systemd.services."getty@tty1".enable = lib.mkForce false;
    systemd.services."autovt@tty1".enable = lib.mkForce false;

    # Note: with autologin, the 'login' keyring will still require unlock when applications request access
    # Without autologin, it will automatically be unlocked, but ether way you need to enter a password once
    # https://askubuntu.com/questions/918712/the-login-keyring-did-not-get-unlocked-when-you-logged-into-your-computer
    services.gnome.gnome-keyring.enable = true;

    environment.gnome.excludePackages = with pkgs; [
      epiphany # browser
      geary # mail reader
      gnome-shell-extensions # This seems to remove default extensions
      gnome-tour
      totem # video player
    ];

    # Sound
    services.pulseaudio.enable = false;
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
            "x-systemd.automount" # Mount on demand (fixes not mounting on boot)

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

    environment.systemPackages = with pkgs; [
      sshfs # Can't be in user
    ];

    system.userActivationScripts = {
      # pub key is required for seahorse to autoadd to ssh-agent
      # ssh-agent is used by vscode to forward ssh credentials to remote machines
      generateSshPubKeyFile = {
        text = ''
          ${pkgs.openssh}/bin/ssh-keygen -y -f ~/.ssh/id_ed25519 > ~/.ssh/id_ed25519.pub
        '';
      };
    };

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

    # Early OOM Killer - Fedora uses it
    # https://fedoraproject.org/wiki/Changes/EnableEarlyoom
    # Without this, desktop hangs occur in cases of high memory pressure
    services.earlyoom = {
      enable = true;
      enableNotifications = true;
    };

    # Enable sysrq
    boot.kernel.sysctl."kernel.sysrq" = 1;
  };
}
