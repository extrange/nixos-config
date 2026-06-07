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
  sops.secrets = {
    "chanel/irasuser".owner = user;
    "chanel/syncthing/key".owner = user; # Allow syncthing to copy the key
  };
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
        xkb-options = lib.mkForce [ ];
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
      cert = "${./syncthing-cert.pem}";
      key = config.sops.secrets."chanel/syncthing/key".path;
      settings = {
        options = {
          urAccepted = -1; # Decline usage reporting
        };
        devices = {
          server.id = "VE43VRC-5MUVL3A-CDIUUQI-3P5VTUZ-Y2YVRTY-HRIJN2U-5JAKLHC-XOYZCAX";
        };
        folders = {
          storage = {
            path = "~/storage";
            id = "upads-r9u37";
            devices = [ "server" ];
          };
          relationship = {
            path = "~/relationship";
            id = "dvz3s-wetzy";
            devices = [ "server" ];
          };
        };
      };
    };
  };
}
