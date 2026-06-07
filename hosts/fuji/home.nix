{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}:
let
  user = config.userName;

in

{
  sops.secrets."chanel/irasuser".owner = user;
  home-manager.users."${user}" = {

    # .config files
    home.file = {
      ".config/background" = lib.mkForce {
        source = ./background.jpg;
        force = true;
      };
      ".config/gtk-3.0/bookmarks" = lib.mkForce {
        text = ''
          file:///home/${user}/Downloads Downloads
          file:///home/${user}/Pictures Pictures
          file:///home/${user}/Videos Videos
        '';
      };
    };

    home.packages = with pkgs; [
      # Desktop programs
      libgourou
      logseq
      vlc
    ];

    programs = {
      git = {
        settings = lib.mkForce { };
        signing = lib.mkForce { };
      };
      ssh.settings = lib.mkForce {
        vm = {
          host = "vm";
          user = "chanel";
        };

        azure-chanel = {
          hostname = "csid.southeastasia.cloudapp.azure.com";
          user = "chanel";
        };

        "ssh.dev.azure.com" = {
          identityFile = config.sops.secrets."chanel/irasuser".path;
        };
      };
    };

    dconf.settings = with home-manager.lib.hm.gvariant; {
      "org/gnome/shell" = {
        # Setup dash shortcuts
        favorite-apps = lib.mkForce [
          "firefox.desktop"
          "org.gnome.Nautilus.desktop"
          "Logseq.desktop"
          "code.desktop"
          "org.telegram.desktop.desktop"
          "org.gnome.Console.desktop"
        ];
      };

      "org/gnome/desktop/input-sources" = lib.mkForce {
        sources = [
          (mkTuple [
            "xkb"
            "us"
          ])
        ];
      };

      # Background
      "org/gnome/desktop/background" = lib.mkForce {
        picture-uri = "file:///home/chanel/.config/background";
        picture-uri-dark = "file:///home/chanel/.config/background";
        picture-options = "zoom";
      };

      "org/gnome/Console" = {
        use-system-font = false;
        custom-font = "JetBrains Mono NL 12";
      };

      "org/gnome/desktop/peripherals/touchpad" = {
        tap-to-click = true;
      };
    };

    services.syncthing = {
      enable = true;
    };
  };
}
