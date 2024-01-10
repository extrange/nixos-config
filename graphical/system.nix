{ config, pkgs, lib, self, hostname, ... }:
{

  # Display
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Display: enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "user";
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


  services.keyd = {
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
}
