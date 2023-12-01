{ config, pkgs, ... }:

{
  home.username = "user";
  home.homeDirectory = "/home/user";

  home.keyboard =
    {
      layout = "us";
      # variant = "dvorak";
      options = [ "capslock:backspace" ];
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
      btop # replacement of htop/nmon
      dnsutils # `dig` + `nslookup` 
      ethtool
      file
      firefox
      fzf # A command-line fuzzy finder
      gnupg
      git-credential-manager
      iftop # network monitoring
      iotop # io monitoring
      ipcalc # it is a calculator for the IPv4/v6 addresses
      iperf3
      jq # A lightweight and flexible command-line JSON processor
      lm_sensors # for `sensors` command
      lsof # list open files
      lsscsi
      ltrace # library call monitoring
      libva-utils # vaainfo, check on VAAPI (hw acceleration)
      mtr # A network diagnostic tool
      nil # Nix language server for vscode
      moonlight-qt
      neofetch
      nmap # A utility for network discovery and security auditing
      nnn
      nixpkgs-fmt # Nix formatter
      obsidian
      p7zip
      pciutils # lspci
      ripgrep # recursively searches directories for a regex pattern
      socat # replacement of openbsd-netcat
      strace # system call monitoring
      sysstat
      syncthing
      telegram-desktop
      tree
      unzip
      usbutils # lsusb
      vscode
      which
      xz
      yq-go # yaml processer https://github.com/mikefarah/yq
      zip
      zstd
    ];


  dconf.settings = {
    "org/gnome/mutter" = {
      edge-tiling = true;
    };
    "org/gnome/desktop/input-sources" = {
      xkb-options = "['caps:backspace']";
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

  # Possible permission issues if run as system?
  services.syncthing.enable = true;


  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
