{
  pkgs,
  config,
  ...
}:

{

  # Nix
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];

  sops.age.sshKeyPaths = [ "/home/chanel/.ssh/id_ed25519" ];
  sops.defaultSopsFile = ../secrets.yaml;
  sops.secrets."chanel/irasuser" = { };

  # For ddcutil (monitor brightness control)
  boot.kernelModules = [ "i2c-dev" ];
  services.udev.extraRules = ''
    SUBSYSTEM=="i2c-dev", KERNEL=="i2c-[0-9]*", ATTRS{class}=="0x030000", TAG+="uaccess"
    SUBSYSTEM=="dri", KERNEL=="card[0-9]*", TAG+="uaccess"
  '';
  time.timeZone = "Asia/Singapore";
  i18n.defaultLocale = "en_SG.UTF-8";

  # Core system
  boot.loader.systemd-boot = {
    enable = true;
    memtest86.enable = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  zramSwap.enable = true;

  # Increase zram to 100% of RAM
  zramSwap.memoryPercent = 100;

  # Virtualization
  virtualisation.docker.enable = true;
  environment.systemPackages = with pkgs; [
    libgourou
    shotcut
    logseq
    virtiofsd
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    virtio-win
    win-spice
    adwaita-icon-theme
  ];

  programs.dconf.enable = true;

  # Decrease shutdown time
  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "15s";
  };
  systemd.services."user@".serviceConfig.TimeoutStopSec = "15s";

  # Increase sudo timeout
  security.sudo.extraConfig = "Defaults timestamp_timeout=30";

  # Network
  networking.hostName = "chanel-fuji";
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" ];

  # The default resolver (glibc) has the issue with no internet after resuming from suspend/link changes
  # Appears to be due to tailscale overwriting /etc/resolv.conf (the default nameserver 192.168.1.1 is removed)
  services.resolved.enable = true;

  # Printing
  services.printing.enable = true;

  # Flatpak (mainly for Logseq)
  # services.flatpak.enable = true;

  # Display
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Display: enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "chanel";
  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Sound
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Fix issue with sops-nix keys on a subvolume not being decrypted
  # Turns sops-nix into a systemd service
  # https://github.com/Mic92/sops-nix/issues/721
  services.userborn.enable = true;
  users = {
    users.chanel = {
      isNormalUser = true;
      description = "chanel";
      extraGroups = [
        "networkmanager"
        "wheel"
        "libvirtd"
        "docker"
      ];
    };
  };

  # Disable tracker miners
  services.gnome.localsearch.enable = false;
  services.gnome.tinysparql.enable = false;

  services.gnome.gnome-keyring.enable = true;

  # Remove some gnome packages I don't use
  environment.gnome.excludePackages = with pkgs; [
    epiphany # browser, use firefox instead
    geary # mail reader
    gnome-shell-extensions # This seems to remove default gnome extensions I don't use
    gnome-tour
    totem # video player, use vlc instead
  ];

  services = {

    tailscale = {
      enable = true;
      useRoutingFeatures = "client"; # allow using exit node
    };

  };
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    unixODBC
    unixODBCDrivers.msodbcsql18

  ];
  programs.ssh = {
    knownHosts = {
      "github.com".publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    };
  };

  # Save space
  boot.loader.systemd-boot.configurationLimit = 10;
  nix.gc = {
    # Deletes old generations
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  # Optimization: symlink identical files in store
  nix.optimise.automatic = true;

  # Run btrfs scrub automatically to check disk for errors
  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/" ];
  };

  system.autoUpgrade = {
    enable = true;
    flake = "github:extrange/nixos-config";
    dates = "*-*-* 05:00:00"; # Upgrade daily
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
