# Settings specific to Home Manager
{
  config,
  lib,
  pkgs,
  nnn,
  ...
}:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.user =

    let
      user = config.users.users.user.name;
    in
    {

      # General settings
      home.username = user;
      home.homeDirectory = "/home/${user}";
      home.sessionVariables = {
        EDITOR = "vim";
        NNN_PLUG = "p:preview-tui";
      };

      # Packages for all systems (graphical/headless)
      home.packages = with pkgs; [
        age
        aria2
        awscli2
        bat
        biome
        btop
        btrfs-progs
        compsize
        cryptsetup
        devenv
        direnv
        dmidecode
        dnsutils # `dig` + `nslookup`
        duf
        eksctl
        ethtool
        exiftool
        file
        fio
        # ffmpeg - use the option `ffmpegCustom` instead
        fzf
        gh
        git
        guestfs-tools # virt-sparsify
        iftop
        iotop
        ipcalc
        iperf3
        jq # Command-line JSON processor
        kubectl
        kubernetes-helm
        libheif
        libsecret # for github auth
        libva-utils # vaainfo, check on VAAPI (hw acceleration)
        lm_sensors # for `sensors` command
        lsd # ls replacement with icons
        lshw
        lsof
        lsscsi
        ltrace # library call monitoring
        minikube
        mtr # ping + tracert TUI
        ncdu
        neofetch
        nfs-utils
        nil # Nix language server for vscode
        nixd
        nixfmt # Nix formatter
        nmap
        ntfs3g
        openssl
        p7zip
        parted
        pciutils # lspci
        poppler-utils # pdftocairo, pdftoppm for pdf to image rendering
        postgresql
        pre-commit
        ripgrep # recursively searches directories for a regex pattern
        sanoid
        smartmontools
        socat
        sops
        sqlfluff
        ssh-to-age
        strace # system call monitoring
        stress-ng
        syncthing
        sysstat
        tree
        treefmt
        unzip
        usbutils # lsusb
        vim
        which
        xz
        yq-go # yaml processer https://github.com/mikefarah/yq
        yt-dlp
        zip
        zstd
      ];

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
            # - not in VSCode, and
            # - over SSH (don't run locally)
            if [[ -z $VSCODE_SHELL_INTEGRATION && ( -n $SSH_CONNECTION ) ]]; then
              eval "$(zellij setup --generate-auto-start bash)"
            fi
          ''
        );
      };

      home.stateVersion = "24.05";
    };
}
