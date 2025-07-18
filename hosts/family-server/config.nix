{
  config,
  specialArgs,
  pkgs,
  lib,
  ...
}:
let
  # Common mount options for local drives
  mountOptions = [
    "nofail"
    "noatime"
    "nosuid"
    "nodev"
    "compress-force=zstd"
  ];
in
{
  addAuthorizedKeys = {
    enable = true;
    forRoot = true; # For virt-manager/qemu kvm access
  };
  ffmpegCustom = true;
  wifi = {
    enable = false;
    interface-name = "wlp0s29u1u4i2";
  };
  uptime = {
    enable = true;
    url = "https://uptime.icybat.com/api/push/4RbFRv0UVQ?status=up&msg=OK&ping=";
  };

  # Required for USB wifi dongle
  # boot.extraModulePackages = with config.boot.kernelPackages; [
  #   rtl8821cu
  # ];

  # No disk encryption
  boot.initrd.luks.devices = lib.mkForce { };

  # Shared folder
  # If a folder in /mnt is used it is owned by root
  fileSystems."/home/user/software" = {
    device = "/dev/disk/by-uuid/83eb9c35-b354-4a0e-9695-e994edeb11fa";
    fsType = "btrfs";
    options = [ "subvol=root" ] ++ mountOptions;
  };

  # VM Storage
  fileSystems."/mnt/vm-storage" = {
    device = "/dev/disk/by-uuid/1b4fda7c-1f93-4edb-8749-a0415ce87360";
    fsType = "btrfs";
    options = [ "subvol=root" ] ++ mountOptions;
  };

  # Deduplication
  # services.beesd.filesystems = {
  #   software = {
  #     spec = "LABEL=software";

  #     # Explanation of .beeshome/beesstats.txt
  #     # https://github.com/Zygo/bees/issues/66#issuecomment-403306685
  #     hashTableSizeMB = 4096;
  #   };
  # };

  # BtrFS autoscrub
  services.btrfs.autoScrub.fileSystems = lib.mkForce [
    "/"
    "/home/user/software"
    "/mnt/vm-storage"
  ];

  # NFS
  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /home/user/software *(rw,all_squash,anonuid=1000,anongid=1000)
  '';
  networking.firewall.allowedTCPPorts = [ 2049 ];

  # Samba
  networking.firewall.allowPing = true;
  services.samba-wsdd = {
    # make shares visible for windows 10 clients
    enable = true;
    openFirewall = true;
  };
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      software = {
        path = "/home/user/software";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "acl allow execute always" = "yes";
        "force user" = "user"; # This is the most important line
      };
      global = {
        workgroup = "WORKGROUP";
        "server string" = "family-server";
        "netbios name" = "family-server";
        security = "user";
        "map to guest" = "bad user";
      };
    };
  };

  # Zellij terminal multiplexer
  home-manager.users.user = {

    programs.zellij = {
      enable = true;
      settings = {
        pane_frames = false;
        ui.pane_frames.hide_session_name = true;
        mouse_mode = false; # Mouse mode messes up copy/paste over SSH
      };
    };

    # initExtra only for interactive
    # Do not run in VSCode
    programs.bash.initExtra = (
      lib.mkOrder 200 ''
        export ZELLIJ_AUTO_ATTACH=true
        export ZELLIJ_AUTO_EXIT=true

        if [[ -z $VSCODE_INJECTION ]]; then
          eval "$(zellij setup --generate-auto-start bash)"
        fi
      ''
    );
  };

  # VSCode Remote Server fix
  programs.nix-ld.enable = true;
}
