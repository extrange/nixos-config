{ config, specialArgs, pkgs, lib, ... }:
{
  # No disk encryption
  boot.initrd.luks.devices = lib.mkForce { };

  # Users allowed to SSH into this server
  users.users."user".openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN3RCwHWzK/gKI8Lplk/qoaoJemh8h/op5Oe7/IXepWK laptop"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINf049gcBU+JxBwkylDpOIGMtk667LfSylzoM1SPZA90 test"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyJ0LttXH9j3Ql7J1ccJbhLWdYhYn24qR6a8ur72hVi desktop"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAm3fEcDvIM7cFCjB3vzBb4YctOGMpjf8X3IxRl5HhjV server"
  ];

  services.openssh = {
    enable = true;
  };

  # If a folder in /mnt is used it is owned by root
  fileSystems."/home/user/software" = {
    device = "/dev/disk/by-uuid/83eb9c35-b354-4a0e-9695-e994edeb11fa";
    fsType = "btrfs";
    options = [
      "subvol=root"
      "nofail"
      "noatime"
      "nosuid"
      "nodev"
      "compress-force=zstd"
    ];
  };

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
      use sendfile = yes
    '';
    shares = {
      software = {
        path = "/home/user/software";
        browsable = "yes";
        writable = "yes";
        "guest ok" = "yes";
        "acl allow execute always" = "yes";
        public = "yes";
      };
    };
  };
}
