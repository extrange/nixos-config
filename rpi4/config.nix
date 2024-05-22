({ config, pkgs, ... }: {

  networking.hostName = "pi";

  # https://github.com/NixOS/nixpkgs/issues/154163
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];
  hardware.raspberry-pi."4".apply-overlays-dtmerge.enable = true;
  hardware.raspberry-pi."4".fkms-3d.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  boot.kernelParams = ["snd_bcm2835.enable_hdmi=1" ];

  nix.settings.trusted-users = [ "root" "@wheel" ];

  # Output as .img instead of .zst
  sdImage.compressImage = false;

  users = {
    users."user" = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" "wheel" ];
      initialHashedPassword = "$y$j9T$hWEXk9oQI3QFayjWyBZep0$xc3zAKoSt4jGvuxrcVMphXKM8b8wlcY61i/R99.pKQ6";

      # Allow desktop to SSH in by default. Password login is still enabled.
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyJ0LttXH9j3Ql7J1ccJbhLWdYhYn24qR6a8ur72hVi user@desktop"
      ];

      packages = with pkgs; [
        moonlight-qt
      ];
    };
  };

  services.openssh.enable = true;
  system.stateVersion = "24.05";
})
