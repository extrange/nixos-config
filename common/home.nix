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
      btop
      btrfs-progs
      compsize
      cryptsetup
      dmidecode
      dnsutils # `dig` + `nslookup`
      duf
      eksctl
      ethtool
      exiftool
      file
      # ffmpeg - use the option `ffmpegCustom` instead
      fzf
      gdu # ncdu-like
      gh
      git
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
      neofetch
      nfs-utils
      nil # Nix language server for vscode
      nixd
      nixfmt-rfc-style # Nix formatter
      nmap
      ntfs3g
      p7zip
      parted
      pciutils # lspci
      poppler_utils # pdftocairo, pdftoppm for pdf to image rendering
      postgresql
      pre-commit
      ripgrep # recursively searches directories for a regex pattern
      smartmontools
      socat
      sops
      ssh-to-age
      strace # system call monitoring
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
          server =
            let
              hostname = "ssh.nicholaslyz.com";
            in
            {
              host = "server ${hostname}";
              inherit hostname;
              port = 39483;
              user = "user";
            };

          # This is so I don't have to specify the user as 'chanel'
          chanel-server =
            let
              hostname = "chanel-server.tail14cd7.ts.net";
            in
            {
              host = "chanel-server ${hostname}";
              inherit hostname;
              user = "chanel";
            };
        };
      };
    };

    # Run as user, ivo possible permission issues if run as system
    services.syncthing.enable = true;

    home.stateVersion = "24.05";
  };
}
