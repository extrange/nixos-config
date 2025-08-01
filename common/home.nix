# Settings specific to Home Manager
{
  config,
  pkgs,
  lib,
  nnn,
  ...
}:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.user = {

    # General settings
    home.username = "user";
    home.homeDirectory = "/home/user";
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
      nixfmt-rfc-style # Nix formatter
      nmap
      ntfs3g
      openssl
      p7zip
      parted
      pciutils # lspci
      poppler_utils # pdftocairo, pdftoppm for pdf to image rendering
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
      wavemon
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
          # TODO fix this alias being overridden by quitcd.bash_sh_zsh
          nnn = "nnn -ae";
        };
        bashrcExtra = builtins.readFile "${nnn}/misc/quitcd/quitcd.bash_sh_zsh";
      };

      home-manager.enable = true;

      git = {
        enable = true;
        userEmail = "29305375+extrange@users.noreply.github.com";
        userName = "extrange";
        signing = {
          format = "ssh";
          key = "/home/${config.users.users.user.name}/.ssh/id_ed25519.pub";
          signByDefault = true;

        };
        delta = {
          enable = true;
          options = {
            side-by-side = true;
          };
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
    };

    home.stateVersion = "24.05";
  };
}
