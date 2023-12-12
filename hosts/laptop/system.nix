{ pkgs, lib, ... }:

{

  hardware.opengl.extraPackages = with pkgs; [
    intel-media-driver
    intel-compute-runtime
  ];

  fileSystems =
    let
      options = {
        options = [
          "noauto"
          "noatime"
          "user"
          "_netdev"
          "allow_other"

          # Fixes sshfs not mounting automatically at boot
          "x-systemd.automount"

        ];
        fsType = "fuse.sshfs";
        noCheck = true; # Disable fsck
      };
    in
    {
      "/mnt/storage" = {
        device = "ssh.nicholaslyz.com:/mnt/storage";
      } // options;

      "/mnt/workspace" = {
        device = "ssh.nicholaslyz.com:/home/user";
      } // options;
    };

  environment.systemPackages = with pkgs; [
    sshfs # Can't be in user
  ];
}
