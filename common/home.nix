# Settings specific to Home Manager
{
  config,
  lib,
  pkgs,
  ...
}:
let
  user = config.users.users.user.name;
in

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.user = {

      # General settings
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
            ls = "lsd";
            df = "duf";
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
            key = "/home/${config.users.users.user.name}/.ssh/id_ed25519.pub";
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
          enableBashIntegration = true;
          shellWrapperName = "y";
        };

        bash.initExtra = (
          # Only in interactive shells (not rsync etc)
          lib.mkOrder 200 ''
            export ZELLIJ_AUTO_ATTACH=true
            export ZELLIJ_AUTO_EXIT=true

            # Only run when:
            # - not in VSCode
            # - over SSH (don't run locally)
            if [[ -z $VSCODE_SHELL_INTEGRATION &&
                  -n $SSH_CONNECTION ]]; then
              eval "$(zellij setup --generate-auto-start bash)"
            fi
          ''
        );
      };

      home.stateVersion = "24.05";
    };
  };
}
