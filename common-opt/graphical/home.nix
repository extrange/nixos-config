# Packages and options for graphical systems
{
  config,
  pkgs,
  lib,
  nnn,
  home-manager,
  pkgs-stable,
  ...
}:
with lib;
{
  config = mkIf config.graphical {
    home-manager.users.user = {
      home.packages = with pkgs; [
        android-tools
        audacity
        azuredatastudio
        calibre
        dbeaver-bin
        discord
        firefox
        gimp
        gnome-extension-manager
        hunspell # libreoffice spellcheck
        hunspellDicts.en-us
        jan
        jellyfin-media-player
        kid3 # audio file tagger
        libreoffice
        lutris
        moonlight-qt
        mpv # required for smplayer
        obs-studio
        obsidian
        pdfarranger
        smplayer
        subsonic
        telegram-desktop
        thunderbird
        ungoogled-chromium
        whatsapp-for-linux
        wineWowPackages.waylandFull
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
        nerd-fonts.jetbrains-mono
        nerd-fonts.fira-code
        open-sans
        source-sans
        jetbrains-mono # has ligatures
      ];

      programs.vscode = {
        # See settings here
        # https://github.com/nix-community/home-manager/blob/master/modules/programs/vscode.nix
        enable = true;

        # Workaround for continue.dev extension not working
        # We use vscode.fhs as continue uses libstdc++
        package = pkgs.vscode.fhsWithPackages (ps: [
          (ps.openssh.overrideAttrs (prev: {
            # Fix remote-ssh not working on vscode.fhs
            # https://github.com/nix-community/home-manager/issues/322
            patches = (prev.patches or [ ]) ++ [ ./openssh-nocheckcfg.patch ];
          }))
        ]);
        # Note: sudo doesn't work in vscode.fhs
        # https://discourse.nixos.org/t/sudo-does-not-work-from-within-vscode-fhs/14227/2
      };

      fonts.fontconfig.enable = true;

      # Turn notifications and GSConnect on and off based on time
      systemd.user =
        let
          # Do‑not‑disturb window as HH:MM strings
          dndStart = "18:00";
          dndEnd = "07:00";
          scriptName = "dnd-toggle";

          toggleScript = pkgs.writeShellApplication {
            name = scriptName;
            runtimeInputs = [ pkgs.dconf ];
            text = ''
              time_now=10#$(date +%H%M)
              start=10#$(echo '${dndStart}' | tr -d ':')  # "18:00" → "1800"
              end=10#$(echo '${dndEnd}' | tr -d ':')      # "07:00" → "0700"

              # enable only if current ∈ [end, start)
              if [[ "$time_now" -ge "$end" ]] && [[ "$time_now" -lt "$start" ]]; then
                echo "Enabling GSConnect and notifications"
                dconf write /org/gnome/shell/extensions/gsconnect/enabled true
                dconf write /org/gnome/desktop/notifications/show-banners true
                echo "GSConnect and notifications enabled"
              else
                echo "Disabling GSConnect and notifications"
                dconf write /org/gnome/shell/extensions/gsconnect/enabled false
                dconf write /org/gnome/desktop/notifications/show-banners false
                echo "GSConnect and notifications disabled"
              fi
            '';
          };

          # Convert "HH:MM" → "*-*-* HH:MM:00"
          toSystemdTime =
            time:
            let
              hh = builtins.substring 0 2 time;
              mm = builtins.substring 3 2 time;
            in
            "*-*-* ${hh}:${mm}:00";

        in
        {
          services.dnd-toggle = {
            Unit = {
              Description = "Toggle notifications and GSConnect based on DND hours";
              Wants = [ "graphical-session.target" ];
              After = [ "graphical-session.target" ];
            };
            Service = {
              Type = "oneshot";
              ExecStart = "${toggleScript}/bin/${scriptName}";
            };
          };

          timers.dnd-toggle = {
            Unit.Description = "Run DND toggle at start/end of DND hours";
            Timer.OnCalendar = [
              (toSystemdTime dndStart)
              (toSystemdTime dndEnd)
            ];
            Timer.Persistent = true;
            Install.WantedBy = [ "timers.target" ];
          };
        };

      # .config files
      home.file = {

        ".config/background" = {
          source = ./.config/background;
          force = true;
        };

        ".config/wasistlos/settings.conf" = {
          source = ./.config/wasistlos/settings.conf;
          force = true;
        };

        # SSHFS bookmarks
        ".config/gtk-3.0/bookmarks" = {
          source = ./bookmarks;
          force = true;
        };
      };

      dconf.settings = with home-manager.lib.hm.gvariant; {

        # Virt-manager connections
        "org/virt-manager/virt-manager/connections" = {
          autoconnect = [ "qemu+ssh://root@server/system" ];
          uris = [ "qemu+ssh://root@server/system" ];
        };

        "org/gnome/mutter" = {
          # Snap windows to top/horizontal edges
          edge-tiling = true;
        };

        "org/gnome/desktop/input-sources" = {
          # Remap capslock to backspace
          xkb-options = [
            "terminate:ctrl_alt_bksp"
            "caps:backspace"
          ];
          # Set Dvorak keyboard layout
          sources = [
            (mkTuple [
              "xkb"
              "us+dvorak"
            ])
            (mkTuple [
              "xkb"
              "us"
            ])
          ];
        };

        "org/gnome/settings-daemon/plugins/color" = {
          night-light-enabled = true;
          night-light-schedule-from = 19.0;
          night-light-schedule-to = 6.0;
          night-light-temperature = mkUint32 1400; # Minimum is 1000
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
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          ];
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
            "discord.desktop"
            "com.github.xeco23.WasIstLos.desktop"
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

        # Dash-to-dock
        "org/gnome/shell/extensions/dash-to-dock" = {
          transparency-mode = "DYNAMIC";
          show-trash = false;
        };

        "org/gnome/Console" = {
          use-system-font = false;
          custom-font = "JetBrains Mono NL 12";
        };

        # Disable search completely
        "org/freedesktop/tracker/miner/files" = {
          index-recursive-directories = [ ];
          index-single-directories = [ ];
        };
        "org/gnome/desktop/search-providers" = {
          disable-external = true;
        };
      };
    };
  };
}
