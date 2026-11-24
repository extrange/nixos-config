# Standalone OpenCode web server.
#
# This only configures the server; the OpenCode CLI/package is installed for
# graphical hosts in common-opt/graphical/home.nix.
#
# This runs `opencode serve` under the user's systemd manager. It is not the
# shared `opencode serve --service` instance, so local clients have to use
# `OPENCODE_PASSWORD=... opencode --server http://127.0.0.1:<port>` to share
# its sessions.
{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.openCodeServer;
  user = config.userName;
in
{
  options.openCodeServer = {
    enable = mkEnableOption "the standalone OpenCode web server";

    hostname = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "Address for the OpenCode server to listen on.";
    };

    port = mkOption {
      type = types.port;
      default = 4096;
      description = "TCP port for the OpenCode server.";
    };

    passwordSecret = mkOption {
      type = types.str;
      default = "opencode/password/${config.networking.hostName}";
      description = "sops secret containing the OpenCode server password.";
    };

    apiKeySecret = mkOption {
      type = types.str;
      default = "opencode/go_api_keys/${config.networking.hostName}";
      description = "sops secret containing the OpenCode Go API key.";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."${cfg.passwordSecret}".owner = user;
    sops.secrets."${cfg.apiKeySecret}".owner = user;

    sops.templates."opencode-web-env" = {
      path = "/run/secrets/rendered/opencode-web-env";
      owner = user;
      mode = "0400";
      content = ''
        OPENCODE_PASSWORD=${config.sops.placeholder."${cfg.passwordSecret}"}
      '';
    };

    # Only expose the server over Tailscale; the password is the second layer.
    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ cfg.port ];

    home-manager.users."${user}".programs.opencode = {
      web = {
        enable = true;
        extraArgs = [
          "--hostname"
          cfg.hostname
          "--port"
          (toString cfg.port)
        ];
        environmentFile = config.sops.templates."opencode-web-env".path;
      };

      settings.providers."opencode-go".settings.apiKey = "{file:${
        config.sops.secrets."${cfg.apiKeySecret}".path
      }}";
    };
  };
}
