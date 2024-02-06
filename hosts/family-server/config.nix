{ config, specialArgs, pkgs, lib, ... }:
let
  authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN3RCwHWzK/gKI8Lplk/qoaoJemh8h/op5Oe7/IXepWK laptop"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINf049gcBU+JxBwkylDpOIGMtk667LfSylzoM1SPZA90 test"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyJ0LttXH9j3Ql7J1ccJbhLWdYhYn24qR6a8ur72hVi desktop"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEZXrm0AXgoOcJWckgr/ZgYVdHKrJHJg5G52bIx6zc4b server"

  ];

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
  wifi = {
    enable = false;
    interface-name = "wlp0s29u1u4i2";
  };

  # Required for USB wifi dongle
  # boot.extraModulePackages = with config.boot.kernelPackages; [
  #   rtl8821cu
  # ];

  # No disk encryption
  boot.initrd.luks.devices = lib.mkForce { };


  # Users allowed to SSH into this server
  users.users."user".openssh.authorizedKeys.keys = authorizedKeys;
  users.users."root".openssh.authorizedKeys.keys = authorizedKeys;

  services.openssh = {
    enable = true;
  };

  # GPU passthrough
  boot.kernelParams = [ "intel_iommu=on" "vfio-pci.ids=10de:1b80" ];
  boot.kernelModules = [ "vfio_pci" "vfio_iommu_type1" "vfio" ];
  boot.initrd.kernelModules = [ "vfio_pci" "vfio_iommu_type1" "vfio" ];
  boot.blacklistedKernelModules = [ "nvidia" "nouveau" ];

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
  services.beesd.filesystems = {
    software = {
      spec = "LABEL=software";
      hashTableSizeMB = 2048;
    };
  };

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
    securityType = "user";
    openFirewall = true;
    extraConfig = ''
      workgroup = WORKGROUP
      server string = family-server
      netbios name = family-server
      security = user 
      map to guest = bad user
    '';
    shares = {
      software = {
        path = "/home/user/software";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "acl allow execute always" = "yes";
        "force user" = "user"; # This is the most important line
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
      };
    };

    # initExtra only for interactive
    # Do not run in VSCode
    programs.bash.initExtra = (lib.mkOrder 200 ''
      export ZELLIJ_AUTO_ATTACH=true
      export ZELLIJ_AUTO_EXIT=true

      if [[ -z $VSCODE_INJECTION ]]; then
        eval "$(zellij setup --generate-auto-start bash)"
      fi
    '');
  };
}
