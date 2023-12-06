{ config, pkgs, lib, ... }:

{
  home.username = "user";
  home.homeDirectory = "/home/user";
  fonts.fontconfig.enable = true;

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
      firefox
      gnome-extension-manager
      moonlight-qt
      obsidian
      syncthing
      telegram-desktop
      whatsapp-for-linux
      vscode

      # Gnome Extensions
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
      bat
      btop
      btrfs-progs
      cryptsetup
      dnsutils # `dig` + `nslookup` 
      ethtool
      file
      fzf
      git
      gh
      iftop
      iotop
      ipcalc
      iperf3
      jq # Command-line JSON processor
      libva-utils # vaainfo, check on VAAPI (hw acceleration)
      lm_sensors # for `sensors` command
      lsof
      lsd # ls replacement with icons
      lsscsi
      ltrace # library call monitoring
      mtr # ping + tracert TUI
      neofetch
      nil # Nix language server for vscode
      nixpkgs-fmt # Nix formatter
      nmap
      nnn
      p7zip
      parted
      pciutils # lspci
      ripgrep # recursively searches directories for a regex pattern
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

  programs.bash.shellAliases = {
    ls = "lsd";
    grep = "grep --color=auto";
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
        "clipboard-indicator@tudmotu.com"
        "dash-to-dock@micxgx.gmail.com"
        "fullscreen-avoider@noobsai.github.com"
        "gsconnect@andyholmes.github.io"
        "Vitals@CoreCoding.com"
      ];

    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      show-trash = false;
    };

    "org/gnome/Console" = {
      use-system-font = false;
      custom-font = "JetBrainsMonoNL Nerd Font 12";
    };


  };

  programs.git = {
    enable = true;
    userEmail = "29305375+extrange@users.noreply.github.com";
    userName = "extrange";
  };

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
