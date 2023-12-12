{ config, pkgs, lib, ... }:

{

  home.username = "user";
  home.homeDirectory = "/home/user";
  fonts.fontconfig.enable = true;
  home.sessionVariables = {
    EDITOR = "vim";
    NNN_PLUG = "p:preview-tui";
  };

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # ''

  # Packages that should be installed to the user profile.
  home.packages = with pkgs;
    [
      # Desktop programs
      calibre
      firefox
      gimp
      gnome-extension-manager
      jellyfin-media-player
      libreoffice
      moonlight-qt
      mission-center # pretty system monitor
      obs-studio
      obsidian
      syncthing
      telegram-desktop
      vlc
      vscode
      whatsapp-for-linux
      zoom-us

      # Gnome Extensions
      gnomeExtensions.blur-my-shell
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.dash-to-dock
      gnomeExtensions.fullscreen-avoider
      gnomeExtensions.gsconnect
      gnomeExtensions.tailscale-status
      gnomeExtensions.vitals

      # Fonts
      (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
      open-sans
      source-sans
      jetbrains-mono # has ligatures

      # Command line
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
      ripgrep # recursively searches directories for a regex pattern
      smartmontools
      socat
      strace # system call monitoring
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

  programs.nnn = {
    enable = true;
    package = pkgs.nnn.override ({ withNerdIcons = true; });
    plugins.src = (pkgs.fetchFromGitHub {
      owner = "jarun";
      repo = "nnn";
      rev = "v4.0";
      sha256 = "sha256-Hpc8YaJeAzJoEi7aJ6DntH2VLkoR6ToP6tPYn3llR7k=";
    }) + "/plugins";
  };

  programs.bash.shellAliases = {
    ls = "lsd";
    grep = "grep --color=auto";
    nnn = "nnn -aeH";
  };

  dconf.settings = with lib.hm.gvariant; {
    "org/gnome/mutter" = {
      # Snap windows to top/horizontal edges
      edge-tiling = true;
    };

    "org/gnome/desktop/input-sources" = {
      # Remap capslock to backspace
      xkb-options = [ "terminate:ctrl_alt_bksp" "caps:backspace" ];
      # Set Dvorak keyboard layout
      sources = [ (mkTuple [ "xkb" "us+dvorak" ]) ];
    };

    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-temperature = mkUint32 1700;
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };

    # Set Alt-Tab to switch between windows, instead of applications
    "org/gnome/desktop/wm/keybindings" = {
      switch-applications = "@as []";
      switch-windows = [ "<alt>Tab" ];
    };

    # Open terminal with Ctrl + Alt + T
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Control><Alt>t";
      command = "kgx";
      name = "Launch terminal";
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [ "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/" ];
    };

    # Show thumbnails on SSH drives
    "org/gnome/nautilus/preferences" = {
      show-image-thumbnails = "always";
    };

    "org/gnome/shell" = {
      # Setup dash shortcuts
      favorite-apps = [
        "firefox.desktop"
        "org.gnome.Console.desktop"
        "obsidian.desktop"
        "org.gnome.Nautilus.desktop"
        "telegram.desktop"
        "code.desktop"
      ];

      # Enable extensions
      enabled-extensions = [
        "blur-my-shell@aunetx"
        "clipboard-indicator@tudmotu.com"
        "dash-to-dock@micxgx.gmail.com"
        "fullscreen-avoider@noobsai.github.com"
        "gsconnect@andyholmes.github.io"
        "Vitals@CoreCoding.com"
      ];

    };

    # Background
    "org/gnome/desktop/background" = {
      picture-uri = "file:///home/user/.config/background";
      picture-uri-dark = "file:///home/user/.config/background";
      picture-options = "zoom";
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      show-trash = false;
    };

    "org/gnome/Console" = {
      use-system-font = false;
      custom-font = "JetBrainsMonoNL Nerd Font 12";
    };
  };

  home.file.".config/background" = {
    source = ./background;
    force = true;
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      server = {
        host = "server ssh.nicholaslyz.com";
        hostname = "ssh.nicholaslyz.com";
        port = 39483;
        user = "user";
      };
      chanel = {
        hostname = "chanel-server.tail14cd7.ts.net";
        user = "chanel";
      };
    };
  };

  programs.git = {
    enable = true;
    userEmail = "29305375+extrange@users.noreply.github.com";
    userName = "extrange";
  };

  # Use git-credential-oauth as the helper instead of personal access tokens
  programs.git-credential-oauth.enable = true;

  programs.starship = {
    enable = true;
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
  };

  # Run as user, ivo possible permission issues if run as system
  services.syncthing.enable = true;


  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
}
