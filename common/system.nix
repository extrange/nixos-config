# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  lib,
  self,
  hostname,
  ...
}:

{
  # Nix
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
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
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.supportedFilesystems = [
    "ntfs"
    "zfs"
  ];
  boot.zfs.forceImportRoot = false;

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 0;
  boot.loader.efi.canTouchEfiVariables = true;

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  # Optimize swap on zram
  # https://wiki.archlinux.org/title/Zram#Optimizing_swap_on_zram
  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
  };

  # Encryption is enabled by default. Individual devices override this
  boot.initrd.luks.devices."luks-primary" = {
    device = "/dev/disk/by-label/primary";

    # Bypass internal dm-crypt workqueues on SSDs to fix freezing problems
    # Note: probably only for SSDs.
    # https://blog.cloudflare.com/speeding-up-linux-disk-encryption/
    # https://dannyvanheumen.nl/post/prevent-linux-system-freezes-dmcrypt-luks-configuration/
    bypassWorkqueues = true;
  };

  # Enable btrfs compression on /
  fileSystems."/".options = [ "compress=zstd" ];

  # Libvirt
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  # Docker/Kubernetes
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  # Decrease systemd shutdown timer duration
  # Written to /etc/systemd/system.conf
  # Verify with `systemctl show --all | grep -i timeout`
  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "15s";
  };

  # By setting the timeout for the user manager itself, it applies to all user services
  # https://wiki.archlinux.org/title/Systemd/User#Changing_the_timeout_value
  # Verify with `systemctl show --all user@1000.service | grep -i timeout`
  systemd.services."user@".serviceConfig.TimeoutStopSec = "15s";

  security.sudo.extraConfig = "Defaults timestamp_timeout=30"; # 30 mins

  systemd.services."getty@tty1".enable = true;
  systemd.services."autovt@tty1".enable = true;

  # Network
  networking.hostName = hostname;
  networking.hostId = builtins.substring 0 8 (builtins.hashString "sha256" hostname);
  networking.networkmanager.enable = true;

  networking.nameservers = [ "1.1.1.1" ];

  # The default resolver (glibc) has the issue with no internet after resuming from suspend/link changes
  # Appears to be due to tailscale overwriting /etc/resolv.conf (the default nameserver 192.168.1.1 is removed)
  services.resolved = {
    enable = true;
    dnssec = "true";
    domains = [ "~." ]; # All domains
    dnsovertls = "true";
  };

  # userborn aims to replace the old perl script
  # https://nixos.org/manual/nixos/stable/#sec-userborn
  # It also lets sops-nix run as a systemd service, which fixes issues with
  # SSH keys in subvolumes not being available at boot
  services.userborn.enable = true;

  users = {
    mutableUsers = false;
    users."user" = {
      isNormalUser = true;
      description = "user";
      extraGroups = [
        "networkmanager"
        "wheel"
        "libvirtd"
        "kvm"
      ];
      hashedPasswordFile = config.sops.secrets.userPassword.path;
    };
  };

  # Configuration options applied on build-vm
  virtualisation.vmVariant = {
    # Override our default password so we can sudo
    users.users.user = {
      password = "12345";
      hashedPasswordFile = lib.mkForce null;
    };

    # nixos-rebuild build-vm: Mount the hosts SSH key so the VM can decrypt secrets
    virtualisation.sharedDirectories = {
      ssh = {
        source = "$HOME/.ssh/id_ed25519"; # Substituted by the host's shell (and user)
        target = "/home/${config.users.users.user.name}/.ssh/id_ed25519";
      };
    };
    virtualisation.memorySize = 2048;
  };

  services = {

    tailscale = {
      enable = true;
      useRoutingFeatures = "client"; # allow using exit node
    };

  };

  programs.ssh = {
    knownHosts = {
      # Added to /etc/ssh/ssh_known_hosts (global)
      # Hostnames given here are their Tailscale MagicDNS names/LAN IPs
      "ssh.nicholaslyz.com,server,192.168.184".publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAm3fEcDvIM7cFCjB3vzBb4YctOGMpjf8X3IxRl5HhjV";

      "192.168.1.238,family-server".publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK7MT+3VHbkXr/nj6Z/a3WGrPy8W4eWa81vgtOKOs2Qc";

      "ssh.icybat.com".publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHEn/IvLVDjLJCIhAs8jPOhFUeE+T6gIxKXVpL2o/sMo";

      "chanel-server.tail14cd7.ts.net".publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIATcbSmh4g3C4c+CDd0X8iIRaJjq9cf6nVu9mpo2lSN8";

      "chanel-fedora.tail14cd7.ts.net".publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH4ETTbz3fgYTc7X5H5diG/tHl8sWcrqLKlqlPvqq7X0";

      "github.com".publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    };

    # Added to /etc/ssh/ssh_config (used by root and all users)
    #
    # Required for SSHFS (SSH client run as root)
    # Otherwise, the root's IdentityFile is used (/root/.ssh) which is not recognized
    extraConfig = ''
      Host ssh.nicholaslyz.com
        HostName ssh.nicholaslyz.com
        Port 39483
        User user
        IdentityFile /home/user/.ssh/id_ed25519
    '';
  };

  # Optimization: symlink identical files in store
  # nix.settings.auto-optimise-store = true; # Run during every build, may slow down builds
  nix.optimise.automatic = true; # Run daily at 0345

  # Save space
  boot.loader.systemd-boot.configurationLimit = 10; # Only saves space in /boot
  nix.gc = {
    # Deletes old generations
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  services.btrfs.autoScrub = {
    enable = true;

    # Filesystems not detected automatically since LUKS is being used
    fileSystems = [ "/" ];
  };

  # Autoupgrades
  system.autoUpgrade = {
    enable = true;
    flake = "github:extrange/nixos-config";
    dates = "*-*-* 05:00:00";
    operation = "switch"; # Upgrade immediately
    persistent = true;
    randomizedDelaySec = "45min";
    flags = [ "-L" ]; # Print full build logs on stderr
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
