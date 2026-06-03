{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.chanel = {
      # General settings
      home.username = "chanel";
      home.homeDirectory = "/home/chanel";
      fonts.fontconfig.enable = true;
      home.shell.enableBashIntegration = true;

      # .config files
      home.file = {
        ".config/background" = {
          source = ./background.jpg;
          force = true;
        };

        ".ssh/irasuser" = {
          source = config.sops.secrets."chanel/irasuser".path;
        };
      };

      home.packages = with pkgs; [
        # Desktop programs
        calibre
        dbeaver-bin
        ddcutil
        firefox
        gimp
        gnome-extension-manager
        libreoffice
        lutris
        moonlight-qt
        devenv
        obs-studio
        syncthing
        telegram-desktop
        ungoogled-chromium
        vlc
        vscode
        wineWow64Packages.waylandFull
        zoom-us

        # Gnome Extensions
        gnomeExtensions.blur-my-shell
        gnomeExtensions.clipboard-indicator
        gnomeExtensions.dash-to-dock
        gnomeExtensions.fullscreen-avoider
        gnomeExtensions.gsconnect
        gnomeExtensions.tailscale-status
        gnomeExtensions.vitals
        gnomeExtensions.brightness-control-using-ddcutil

        # Fonts
        nerd-fonts.jetbrains-mono
        nerd-fonts.fira-code
        open-sans
        source-sans
        jetbrains-mono # has ligatures

        # Command line
        age
        bat
        btop
        btrfs-progs
        ffmpeg
        file
        fzf
        gh
        git
        hunspell # libreoffice spellcheck
        hunspellDicts.en-us
        iw
        libheif
        libsecret # for github auth
        libva-utils # vaainfo, check on VAAPI (hw acceleration)
        lm_sensors # for `sensors` command
        lsd # ls replacement with icons
        lsof
        lsscsi
        ltrace # library call monitoring
        mtr # ping + tracert TUI
        nixd # Nix language server for vscode
        nixfmt # Nix formatter
        nmap
        nodejs
        p7zip
        parted
        pciutils # lspci
        pre-commit
        ripgrep # recursively searches directories for a regex pattern
        smartmontools
        socat
        sops
        ssh-to-age
        strace # system call monitoring
        sysstat
        tree
        unzip
        usbutils # lsusb
        uv
        vim
        wavemon
        which
        xz
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
          };
        };

        direnv.enable = true;

        home-manager.enable = true;

        # Prettier shell prompt
        starship.enable = true;

        ssh = {
          enable = true;
          enableDefaultConfig = false;

          matchBlocks = {

            chanel-server = {
              host = "chanel-server";
              user = "chanel";
            };

            azure-chanel = {
              hostname = "csid.southeastasia.cloudapp.azure.com";
              user = "chanel";
            };

            "ssh.dev.azure.com" = {
              identityFile = "~/.ssh/irasuser";
            };

          };

        };
      };

      dconf.settings = with home-manager.lib.hm.gvariant; {
        "org/gnome/mutter" = {
          # Snap windows to top/horizontal edges
          edge-tiling = true;
        };

        "org/gnome/settings-daemon/plugins/color" = {
          night-light-enabled = true;
          night-light-temperature = mkUint32 2500;
        };

        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };

        # Set Alt-Tab to switch between windows, instead of applications
        "org/gnome/desktop/wm/keybindings" = {
          switch-applications = "@as []";
          switch-windows = [ "<alt>Tab" ];
        };

        # Show thumbnails on SSH drives
        "org/gnome/nautilus/preferences" = {
          show-image-thumbnails = "always";
        };

        "org/gnome/shell" = {
          # Setup dash shortcuts
          favorite-apps = [
            "firefox.desktop"
            "org.gnome.Nautilus.desktop"
            "Logseq.desktop"
            "code.desktop"
            "org.telegram.desktop.desktop"
            "org.gnome.Console.desktop"
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
            "display-brightness-ddcutil@themightydeity.github.com"
          ];

        };

        # Background
        "org/gnome/desktop/background" = {
          picture-uri = "file:///home/chanel/.config/background";
          picture-uri-dark = "file:///home/chanel/.config/background";
          picture-options = "zoom";
        };

        "org/gnome/shell/extensions/dash-to-dock" = {
          show-trash = false;
        };

        "org/gnome/Console" = {
          use-system-font = false;
          custom-font = "JetBrains Mono NL 12";
        };

        "org/gnome/desktop/peripherals/touchpad" = {
          tap-to-click = true;
        };
      };

      # Run as user, ivo possible permission issues if run as system
      services.syncthing.enable = true;

      home.stateVersion = "24.05";
    };
  };
}
