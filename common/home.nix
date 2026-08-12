# Settings specific to Home Manager
{
  config,
  lib,
  pkgs,
  ...
}:
let
  user = config.userName;
in

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };
  home-manager.users."${user}" = {
    home.username = user;
    home.homeDirectory = "/home/${user}";

    home.file = {
      ".aws/config" = {
        source = ./.aws/config;
        force = true;
      };
    };

    # Application-specific config
    programs = {
      bash = {
        enable = true;
        enableCompletion = true;
        shellAliases = {
          ls = "${lib.getExe pkgs.lsd}";
          df = "${lib.getExe pkgs.duf}";
          watch = "${lib.getExe pkgs.hwatch}";
          grep = "grep --color=auto";
        };
      };

      home-manager.enable = true;

      git = {
        enable = true;
        settings = {
          user = {
            email = "29305375+extrange@users.noreply.github.com";
            name = "extrange";
          };
        };
        signing = {
          format = "ssh";
          key = "/home/${user}/.ssh/id_ed25519.pub";
          signByDefault = true;
        };
      };

      delta = {
        enable = true;
        enableGitIntegration = true;
        options = {
          side-by-side = true;
        };
      };

      starship.enable = true;

      ssh = {
        enable = true;
        enableDefaultConfig = false;

        settings = {

          server = {
            Hostname = "ssh.nicholaslyz.com";
            Port = 39483;
            User = "user";
          };

          chanel-server = {
            Hostname = "chanel-server.tail14cd7.ts.net";
            User = "chanel";
          };

          chanel-vm = {
            Hostname = "chanel-vm.tail14cd7.ts.net";
            User = "chanel";
          };

          router = {
            Hostname = "192.168.1.1";
            User = "admin";
          };
        };
      };

      zellij = {
        enable = true;
        settings = {
          pane_frames = false;
          ui.pane_frames.hide_session_name = true;
          show_startup_tips = false;
        };
      };

      yazi = {
        enable = true;
        shellWrapperName = "y";
      };

      bash.initExtra = lib.mkOrder 200 (
        # Devenv
        ''
          # Start devenv shell automatically on entering directories
          eval "$(devenv hook bash)"
        ''
        # Zellij
        + ''
          # Only run zellij in interactive shells (not rsync etc). Specifically:
          # - not in VSCode
          # - over SSH (don't run locally)
          if [[ -z $VSCODE_SHELL_INTEGRATION &&
                -n $SSH_CONNECTION ]]; then
            eval "$(zellij setup --generate-auto-start bash)"
          fi

          # Fix garbled mouse commands appearing when SSH crashes with Zellij
          # https://github.com/zellij-org/zellij/issues/4371
          reset_mouse_tracking() { printf '\e[?1000l\e[?1002l\e[?1003l\e[?1006l'; }
          PROMPT_COMMAND="reset_mouse_tracking''${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
        ''
      );

    };

    home.sessionVariables = {
      # If the zellij session already exists, attach to the default session. (not starting as a new session)
      ZELLIJ_AUTO_ATTACH = "true";
      # When zellij exits, the shell exits as well.
      ZELLIJ_AUTO_EXIT = "true";
    };

    home.stateVersion = "24.05";
  };
}
