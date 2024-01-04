{ config, pkgs, lib, nnn, ... }:

{
  # General settings
  home.username = "user";
  home.homeDirectory = "/home/user";
  fonts.fontconfig.enable = true;
  home.sessionVariables = {
    EDITOR = "vim";
    NNN_PLUG = "p:preview-tui";
  };

  # .config files
  home.file = {

    ".config/background" = {
      source = ./.config/background;
      force = true;
    };

    ".config/whatsapp-for-linux/settings.conf" = {
      source = ./.config/whatsapp-for-linux/settings.conf;
      force = true;
    };

    # SSHFS bookmarks
    ".config/gtk-3.0/bookmarks" = {
      source = ./bookmarks;
      force = true;
    };
  };


  home.packages = with pkgs;
    [
      # Desktop programs
      calibre
      discord
      firefox
      gimp
      gnome-extension-manager
      jellyfin-media-player
      libreoffice
      mission-center # pretty system monitor
      moonlight-qt
      mpv # required for smplayer
      obs-studio
      obsidian
      pdfarranger
      smplayer
      shotcut
      syncthing
      telegram-desktop
      ungoogled-chromium
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
        "code.desktop"
        "org.telegram.desktop.desktop"
        "com.github.eneshecan.WhatsAppForLinux.desktop"
      ];

      # Enable extensions
      enabled-extensions = [
        "blur-my-shell@aunetx"
        "clipboard-indicator@tudmotu.com"
        "dash-to-dock@micxgx.gmail.com"
        "fullscreen-avoider@noobsai.github.com"
        "gsconnect@andyholmes.github.io"
        "tailscale-status@maxgallup.github.com"
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

  # Run as user, ivo possible permission issues if run as system
  services.syncthing.enable = true;

  home.stateVersion = "24.05";
}
