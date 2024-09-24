{ lib, config, ... }:
with lib;
{
  options.addSshKeys = mkOption {
    type = types.bool;
    description = "Whether to add authorized keys for SSH for both user and root";
    example = true;
    default = false;
  };

  config =
    let
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN3RCwHWzK/gKI8Lplk/qoaoJemh8h/op5Oe7/IXepWK laptop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINf049gcBU+JxBwkylDpOIGMtk667LfSylzoM1SPZA90 test"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyJ0LttXH9j3Ql7J1ccJbhLWdYhYn24qR6a8ur72hVi desktop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEZXrm0AXgoOcJWckgr/ZgYVdHKrJHJg5G52bIx6zc4b server"

      ];
    in
    mkIf config.addSshKeys {
      users.users."user".openssh.authorizedKeys.keys = authorizedKeys;
      users.users."root".openssh.authorizedKeys.keys = authorizedKeys; # allow root login for virt-manager/qemu kvm access
    };
}
