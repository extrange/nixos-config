{ config, pkgs, lib, nnn, ... }:

{
  # General settings
  home.username = "user";
  home.homeDirectory = "/home/user";
  home.sessionVariables = {
    EDITOR = "vim";
    NNN_PLUG = "p:preview-tui";
  };

  # Packages for all systems (graphical/headless)
  home.packages = with pkgs;
    [
      age
      bat
      btop
      btrfs-progs
      cryptsetup
      dnsutils # `dig` + `nslookup` 
      ethtool
      (ffmpeg.override { withFdkAac = true; withUnfree = true; })
      file
      fzf
      gh
      git
      hunspell # libreoffice spellcheck
      hunspellDicts.en-us
      iftop
      iotop
      ipcalc
      iperf3
      jq # Command-line JSON processor
      libheif
      libsecret # for github auth
      libva-utils # vaainfo, check on VAAPI (hw acceleration)
      lm_sensors # for `sensors` command
      lsd # ls replacement with icons
      lsof
      lsscsi
      ltrace # library call monitoring
      mtr # ping + tracert TUI
      neofetch
      nil # Nix language server for vscode
      nixpkgs-fmt # Nix formatter
      nmap
      p7zip
      parted
      pciutils # lspci
      poppler_utils # pdftocairo, pdftoppm for pdf to image rendering
      ripgrep # recursively searches directories for a regex pattern
      smartmontools
      socat
      ssh-to-age
      sops
      strace # system call monitoring
      syncthing
      sysstat
      tree
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

  # Application-specific config
  programs = {
    bash = {
      enable = true;
      enableCompletion = true;
      shellAliases = {
        ls = "lsd";
        grep = "grep --color=auto";
        # TODO fix this alias being overridden by quetcd.bash_sh_zsh
        nnn = "nnn -ae"; # Can't alias nnn as n, otherwise cd on quit doesn't work
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
      package = pkgs.nnn.override ({ withNerdIcons = true; });
      plugins.src = "${nnn}/plugins";
    };

    starship.enable = true;

    ssh = {
      enable = true;
      # ~.ssh/config
      matchBlocks = let hostname = "ssh.nicholaslyz.com"; in {
        server = {
          host = "server ${hostname}";
          inherit hostname;
          port = 39483;
          user = "user";
        };
        chanel = let hostname = "chanel-server.tail14cd7.ts.net"; in {
          host = "chanel ${hostname}";
          inherit hostname;
          user = "chanel";
        };
      };
    };
  };

  # Run as user, ivo possible permission issues if run as system
  services.syncthing.enable = true;

  home.stateVersion = "24.05";
}
