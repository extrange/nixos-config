{ lib, config, ... }:
with lib;
{
  options.buildRemote = mkEnableOption "Whether to build remotely";

  config = mkIf config.buildRemote {
    # Never build locally
    # Override with --max-jobs 1
    nix.settings.max-jobs = 0;

    nix.distributedBuilds = true;
    nix.buildMachines = [
      {
        hostName = "ssh.nicholaslyz.com"; # Specified in programs.ssh.extraConfig
        systems = [
          "x86_64-linux"
          "i686-linux"
        ];
        protocol = "ssh";
        maxJobs = 6;
        speedFactor = 2;
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
        ];
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
