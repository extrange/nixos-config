{ lib, config, ... }:
with lib;
let
  inherit (types) str submodule;
  sshKey = submodule {
    options = {
      type = mkOption {
        type = str;
        default = "ssh-ed25519";
        description = "SSH key algorithm";
      };
      key = mkOption {
        type = str;
        description = "The actual key material (base64 part)";
      };
    };
  };
  renderKey = lib.mapAttrsToList (k: v: "${v.type} ${v.key} ${k}");

in
{
  options.allowSsh = {
    enable = mkEnableOption "SSH access into this machine";
    forRoot = mkEnableOption "SSH `root` access";

    # These are added to /etc/ssh/authorized_keys.d/<user name>
    authorizedDeviceKeys = mkOption {
      type = types.attrsOf sshKey;
      description = "Authorized SSH keys";
      default = {
        "user@laptop".key = "AAAAC3NzaC1lZDI1NTE5AAAAIN3RCwHWzK/gKI8Lplk/qoaoJemh8h/op5Oe7/IXepWK";
        "user@desktop".key = "AAAAC3NzaC1lZDI1NTE5AAAAIGyJ0LttXH9j3Ql7J1ccJbhLWdYhYn24qR6a8ur72hVi";
        "user@server".key = "AAAAC3NzaC1lZDI1NTE5AAAAIEZXrm0AXgoOcJWckgr/ZgYVdHKrJHJg5G52bIx6zc4b";
        "user@zephyr".key = "AAAAC3NzaC1lZDI1NTE5AAAAIOreujIuA7XmkluU/U8r2Zjjx+Mv1nprYEFXRLj1rwM5";
        "user@alethea".key = "AAAAC3NzaC1lZDI1NTE5AAAAIAVekt8BuiMIgPHlhZorZ+GJfB1TZ7rheUk+07tm6iUc";
      };
    };
  };

  config =
    let
      cfg = config.allowSsh;
    in
    mkIf cfg.enable {
      services.openssh = {
        enable = true;
        settings = {
          # Prevent inactive SSH connections from dropping
          ClientAliveInterval = 15;
        };
      };
      users.users."${config.userName}".openssh.authorizedKeys.keys = renderKey cfg.authorizedDeviceKeys;
      users.users."root".openssh.authorizedKeys.keys = mkIf cfg.forRoot (
        renderKey cfg.authorizedDeviceKeys
      );
    };
}
