{ lib, config, ... }:
with lib;
{
  options.buildRemote = mkOption {
    type = types.bool;
    description = "Whether to build remotely";
    example = true;
    default = false;
  };

  config = mkIf config.buildRemote {
    nix.settings.max-jobs = 0; # Never build locally
    nix.distributedBuilds = true;
    nix.buildMachines = [
      {
        hostName = "ssh.nicholaslyz.com"; # Specified in programs.ssh.extraConfig
        system = "x86_64-linux";
        protocol = "ssh";
        maxJobs = 4;
        speedFactor = 2;
        supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      }
    ];
    nix.extraOptions = ''
      	  builders-use-substitutes = true
      	'';
  };
}
