{ config, pkgs, lib, ... }:
{
  fileSystems."/mnt/storage" = {
    device = "192.168.1.184:/mnt/storage";
    options = [ "noatime" "nofail" "_netdev" ];
    fsType = "nfs";
  };

  fileSystems."/mnt/workspace" = {
    device = "192.168.1.184:/home/user";
    options = [ "noatime" "nofail" "_netdev" ];
    fsType = "nfs";
  };


}
