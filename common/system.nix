# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, self, hostname, ... }:

{
  # Nix
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # sops-nix
  sops.age.sshKeyPaths = [ "/home/user/.ssh/id_ed25519" ];
  sops.defaultSopsFile = ../secrets.yaml;
  sops.secrets.userPassword.neededForUsers = true;

  # i8n
  time.timeZone = "Asia/Singapore";
  i18n.defaultLocale = "en_SG.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_SG.UTF-8";
    LC_IDENTIFICATION = "en_SG.UTF-8";
    LC_MEASUREMENT = "en_SG.UTF-8";
    LC_MONETARY = "en_SG.UTF-8";
    LC_NAME = "en_SG.UTF-8";
    LC_NUMERIC = "en_SG.UTF-8";
    LC_PAPER = "en_SG.UTF-8";
    LC_TELEPHONE = "en_SG.UTF-8";
    LC_TIME = "en_SG.UTF-8";
  };

  # Core system

  # See latest kernels here
  # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/os-specific/linux/kernel/kernels-org.json
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices."luks-primary".device = "/dev/disk/by-label/primary";
  zramSwap.enable = true;

  # Virtualization
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  # System misc config
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=15s
  '';
  security.sudo.extraConfig = "Defaults timestamp_timeout=30";

  # Network
  networking.hostName = hostname;
  networking.networkmanager.enable = true;

  # Display
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Display: enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "user";
  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

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

  users = {
    mutableUsers = false;
    users."user" = {
      isNormalUser = true;
      description = "user";
      extraGroups = [ "networkmanager" "wheel" "libvirtd" "kvm" ];
      hashedPasswordFile = config.sops.secrets.userPassword.path;
    };
  };

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

  services = {

    tailscale = {
      enable = true;
      useRoutingFeatures = "client"; # allow using exit node
    };

    keyd = {
      enable = true;
      keyboards = {
        default = {
          ids = [ "*" ];
          settings = {
            control = {
              z = "C-/";
              x = "C-b";
              c = "C-i";
              v = "C-.";
              t = "C-k";
              w = "C-,";
              # Pressing shift enters a new layer
              shift = "layer(control_shift)";
            };
            # We inherit from the C-S (ctrl+shift) layer
            # This preserves existing ctrl+shift combinations
            "control_shift:C-S" = {
              t = "C-S-k";
            };
          };
        };
      };
    };
  };

  programs.ssh = {
    knownHosts = {
      # User SSH references this
      "ssh.nicholaslyz.com,server,192.168.184".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAm3fEcDvIM7cFCjB3vzBb4YctOGMpjf8X3IxRl5HhjV";

      "ssh.icybat.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHEn/IvLVDjLJCIhAs8jPOhFUeE+T6gIxKXVpL2o/sMo";

      "chanel-server.tail14cd7.ts.net".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHXcEkJzqDxVBOZzL9DfSR5nE+D+Hx+ogDM+Pz+Npvf/";

      "chanel-fedora.tail14cd7.ts.net".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH4ETTbz3fgYTc7X5H5diG/tHl8sWcrqLKlqlPvqq7X0";

      "github.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    };

    # Required for SSHFS (SSH run as root)
    extraConfig = ''
      Host ssh.nicholaslyz.com
        HostName ssh.nicholaslyz.com
        Port 39483
        User user
        IdentityFile /home/user/.ssh/id_ed25519
    '';
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

  environment.systemPackages = with pkgs; [
    sshfs # Can't be in user
  ];

  # Optimization
  boot.loader.systemd-boot.configurationLimit = 10;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };
  nix.settings.auto-optimise-store = true;
  nix.optimise.automatic = true;

  # Autoupgrades
  system.autoUpgrade = {
    # Default frequency is daily
    enable = true;
    flake = self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "--no-write-lock-file"
      "-L" # print build logs
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
