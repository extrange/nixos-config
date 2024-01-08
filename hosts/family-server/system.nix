{ config, specialArgs, pkgs, lib, ... }:
{
  # No need GUI/sound/keyd
  # services.xserver.enable = lib.mkForce false;
  sound.enable = lib.mkForce false;
  services.keyd.enable = lib.mkForce false;
  systemd.services."getty@tty1".enable = lib.mkForce true;
  systemd.services."autovt@tty1".enable = lib.mkForce true;

  # No disk encryption
  boot.initrd.luks.devices = lib.mkForce {};

  # Users allowed to SSH into this served
  users.users."user".openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN3RCwHWzK/gKI8Lplk/qoaoJemh8h/op5Oe7/IXepWK laptop"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINf049gcBU+JxBwkylDpOIGMtk667LfSylzoM1SPZA90 test"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyJ0LttXH9j3Ql7J1ccJbhLWdYhYn24qR6a8ur72hVi desktop"
  ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };
}
