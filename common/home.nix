# Settings specific to Home Manager
{
  config,
  lib,
  pkgs,
  nnn,
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
      home.sessionVariables = {
        EDITOR = "vim";
        NNN_PLUG = "p:preview-tui";
      };

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
            nnn = "nnn -ae";
          };
          bashrcExtra = builtins.readFile "${nnn}/misc/quitcd/quitcd.bash_sh_zsh"; # Allow changing directory on cd
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

        nnn = {
          enable = true;
          package = pkgs.nnn.override { withNerdIcons = true; };
          plugins.src = "${nnn}/plugins";
        };

        starship.enable = true;

        ssh = {
          enable = true;
          enableDefaultConfig = false;

          # ~.ssh/config
          matchBlocks = {

            # This is so I don't have to specify the port my server listens on
            server = {
              hostname = "ssh.nicholaslyz.com";
              port = 39483;
              user = "user";
            };

            # This is so I don't have to specify the user as 'chanel'
            chanel-server = {
              hostname = "chanel-server.tail14cd7.ts.net";
              user = "chanel";
            };

            azure-chanel = {
              hostname = "csid.southeastasia.cloudapp.azure.com";
              user = "chanel";
            };

            router = {
              hostname = "192.168.1.1";
              user = "admin";
            };
          };
        };

        zellij = {
          enable = true;
          settings = {
            pane_frames = false;
            ui.pane_frames.hide_session_name = true;
            mouse_mode = false; # Mouse mode messes up copy/paste over SSH
            show_startup_tips = false;
          };
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
