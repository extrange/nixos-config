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
    # Never build locally
    # Override with --max-jobs 1
    nix.settings.max-jobs = 0;

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

      {
        hostName = "eu.nixbuild.net";
        system = "aarch64-linux";
        maxJobs = 100;
        supportedFeatures = [ "benchmark" "big-parallel" ];
      }
    ];

    # Tell remote machines to fetch their own build substitutes
    # instead of waiting for this host to upload them.
    # https://nix.dev/manual/nix/2.18/command-ref/conf-file.html#conf-builders-use-substitutes
    nix.extraOptions = ''
      	  builders-use-substitutes = true
      	'';
  };
}
