{ lib, config, ... }:
with lib;
{
  options.addAuthorizedKeys = {
    enable = mkEnableOption "Add authorized keys to user";
    forRoot = mkEnableOption "Also add authorized keys to root";
  };

  config =
    let
      cfg = config.addAuthorizedKeys;
      # These are added to /etc/ssh/authorized_keys.d
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN3RCwHWzK/gKI8Lplk/qoaoJemh8h/op5Oe7/IXepWK laptop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINf049gcBU+JxBwkylDpOIGMtk667LfSylzoM1SPZA90 test"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyJ0LttXH9j3Ql7J1ccJbhLWdYhYn24qR6a8ur72hVi desktop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEZXrm0AXgoOcJWckgr/ZgYVdHKrJHJg5G52bIx6zc4b server"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBy46svGzZn4VfcAb3+kp2/5dxvpk3IKzLh1Kn4YCzCb chanel@server"

      ];
    in
    mkIf cfg.enable {
      services.openssh = {
        enable = true;
        settings = {
          # Prevent inactive SSH connections from dropping
          ClientAliveInterval = 15;
        };
      };
      users.users."user".openssh.authorizedKeys.keys = authorizedKeys;
      users.users."root".openssh.authorizedKeys.keys = mkIf cfg.forRoot authorizedKeys;
    };
}
