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

  # https://github.com/Mic92/sops-nix/issues/427
  sops.gnupg.sshKeyPaths = [ ];

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
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ "ntfs" ];
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
  systemd.services."getty@tty1".enable = true;
  systemd.services."autovt@tty1".enable = true;

  # Network
  networking.hostName = hostname;
  networking.networkmanager.enable = true;

  users = {
    mutableUsers = false;
    users."user" = {
      isNormalUser = true;
      description = "user";
      extraGroups = [ "networkmanager" "wheel" "libvirtd" "kvm" ];
      hashedPasswordFile = config.sops.secrets.userPassword.path;
    };
  };

  services = {

    tailscale = {
      enable = true;
      useRoutingFeatures = "client"; # allow using exit node
    };

  };

  programs.ssh = {
    knownHosts = {
      # User's SSH client references this file.
      # Hostnames given here are their Tailscale MagicDNS names
      "ssh.nicholaslyz.com,server,192.168.184".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAm3fEcDvIM7cFCjB3vzBb4YctOGMpjf8X3IxRl5HhjV";

      "192.168.1.238,family-server".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIBvoJfBrYy0N8r9eDwoG5w2YgXSRTZFNlBAX7nDZNhw";

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
  # system.autoUpgrade = {
  #   # Default frequency is daily
  #   enable = true;
  #   flake = self.outPath;
  #   flags = [
  #     "--update-input"
  #     "nixpkgs"
  #     "--no-write-lock-file"
  #     "-L" # print build logs
  #   ];
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
