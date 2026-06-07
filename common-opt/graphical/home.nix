# Packages and options for graphical systems
{
  config,
  pkgs,
  lib,
  home-manager,
  pkgs-stable,
  ...
}:
with lib;
let
  user = config.userName;
in
{
  config = mkIf config.graphical {
    home-manager.users."${user}" = {
      home.packages = with pkgs; [
        android-tools
        audacity
        calibre
        dbeaver-bin
        discord
        firefox
        gimp
        gnome-extension-manager
        hunspell # libreoffice spellcheck
        hunspellDicts.en-us
        jan
        karere
        kid3 # audio file tagger
        libreoffice
        lutris
        moonlight-qt
        mpv # required for smplayer
        obs-studio
        obsidian
        pdfarranger
        remmina
        smplayer
        subsonic
        telegram-desktop
        thunderbird
        ungoogled-chromium
        virt-manager
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

        # Fonts
        nerd-fonts.jetbrains-mono
        nerd-fonts.fira-code
        open-sans
        source-sans
        jetbrains-mono # has ligatures
        (pkgs.callPackage ./allura.nix { })
      ];

      fonts.fontconfig.enable = true;

      # .config files
      home.file = {

        ".config/background" = {
          source = ./.config/background;
          force = true;
        };

        # SSHFS bookmarks
        ".config/gtk-3.0/bookmarks" = {

          text = ''
            file:///home/${user}/Downloads Downloads
            file:///home/${user}/Pictures Pictures
            file:///home/${user}/Videos Videos
            file:///mnt/workspace workspace
            file:///mnt/storage storage
          '';
          force = true;
        };
      };

      programs = {
        ghostty = {
          enable = true;
          installBatSyntax = true;
          installVimSyntax = true;
          settings = {
            background-opacity = 0.9;
            theme = "Atom One Dark";
          };
        };
      };

      dconf.settings =
        with home-manager.lib.hm.gvariant;
        let
          qemuUris = [ "qemu+ssh://root@zephyr/system" ];
        in
        {

          # Virt-manager connections
          "org/virt-manager/virt-manager/connections" = {
            uris = qemuUris;
          };
          "org/virt-manager/virt-manager/connections" = {
            autoconnect = qemuUris;
          };

          # Auto TZ
          "org/gnome/desktop/datetime" = {
            automatic-timezone = true;
          };
          "org/gnome/system/location" = {
            enabled = true;
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
            command = "ghostty";
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

          "org/gnome/settings-daemon/plugins/power" = {
            # Don't sleep on AC power
            sleep-inactive-ac-type = "nothing";
          };

          "org/gnome/shell" = {
            # Setup dash shortcuts
            favorite-apps = [
              "firefox.desktop"
              "com.mitchellh.ghostty.desktop"
              "obsidian.desktop"
              "org.gnome.Nautilus.desktop"
              "code.desktop"
              "org.telegram.desktop.desktop"
              "io.github.tobagin.karere.desktop"
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
            dock-fixed = false;
            show-trash = false;
          };

          # Disable search completely
          "org/freedesktop/tracker/miner/files" = {
            index-recursive-directories = [ ];
            index-single-directories = [ ];
          };
          "org/gnome/desktop/search-providers" = {
            disable-external = true;
          };

          # Whatsapp Client
          "io/github/tobagin/karere" = {
            run-on-startup = true;
            start-in-background = true;
            enable-multi-account = true;
          };
        };
    };
  };
}
