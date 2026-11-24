# OpenCode background server.
#
# This installs the OpenCode package and runs `opencode serve --service` under
# the user's systemd manager. The desktop app discovers and reuses this shared
# service instead of starting its own local server. The desktop app itself is
# installed for graphical hosts in common-opt/graphical/home.nix.
{
  lib,
  config,
  pkgs,
  llm-agents,
  ...
}:
with lib;
let
  cfg = config.openCodeServer;
  user = config.userName;

  # `serve --service` ignores OPENCODE_PASSWORD and reads the password from
  # ~/.config/opencode/service.json. Sync the sops value into that file before
  # each start, preserving unrelated service settings (remote, cors, ...).
  servicePasswordScript = pkgs.writeShellScript "opencode-service-password" ''
    set -eu
    config="$HOME/.config/opencode/service.json"
    tmp="$(${pkgs.coreutils}/bin/mktemp)"
    trap '${pkgs.coreutils}/bin/rm -f "$tmp"' EXIT

    if [ -f "$config" ]; then
      ${pkgs.jq}/bin/jq --arg password "$OPENCODE_PASSWORD" \
        '.password = $password' "$config" > "$tmp"
    else
      ${pkgs.jq}/bin/jq -n --arg password "$OPENCODE_PASSWORD" \
        '{ password: $password }' > "$tmp"
    fi

    ${pkgs.coreutils}/bin/install -D -m 600 "$tmp" "$config"
  '';
in
{
  options.openCodeServer = {
    enable = mkEnableOption "the OpenCode background server";

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

    home-manager.users."${user}" = {
      programs.opencode = {
        enable = true;
        package = llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode2;

        web = {
          enable = true;
          extraArgs = [
            "--service"
            "--hostname"
            # The desktop app's local connection expects the server on localhost.
            # Remote clients use the host's Tailscale IP or MagicDNS name.
            "0.0.0.0"
            "--port"
            (toString cfg.port)
          ];
          environmentFile = config.sops.templates."opencode-web-env".path;
        };

        settings = {
          update = "disable"; # Managed via nix
          providers."opencode-go".settings.apiKey = "{file:${
            config.sops.secrets."${cfg.apiKeySecret}".path
          }}";
        };
      };

      systemd.user.services.opencode-web.Service.ExecStartPre = "${servicePasswordScript}";
    };
  };
}
