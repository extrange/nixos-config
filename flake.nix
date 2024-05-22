{
  description = "My NixOS Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nnn = {
      url = "github:jarun/nnn";
      flake = false;
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
    };
  };

  outputs = { nixpkgs, home-manager, sops-nix, nnn, nixos-hardware, self, ... }:
    with builtins;

    let
      hasSuffix = nixpkgs.lib.hasSuffix;

      getNixFilesInDir = d: map (p: d + "/${p}") (filter (n: hasSuffix ".nix" n) (attrNames (readDir d)));

      mkHost = hostname: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          { config._module.args = { inherit hostname self nnn home-manager; }; }
        ]
        ++ (getNixFilesInDir ./common)
        ++ (getNixFilesInDir ./common-opt)
        ++ (getNixFilesInDir ./hosts/${hostname});
      };
    in
    {
      nixosConfigurations = (mapAttrs
        (hostname: _: mkHost hostname)
        # Get hostnames by reading folder name in hosts/
        (readDir ./hosts)) // {

        # Build ISO with:
        # nix build .#nixosConfigurations.iso.config.system.build.isoImage
        iso = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            # Add rtl8821cu wifi driver
            (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
            ({ pkgs, lib, config, ... }: {
              boot.extraModulePackages = with config.boot.kernelPackages; [
                rtl8821cu
              ];
            })
          ];
        };

        # Raspberry Pi 4
        iso_aarch64 = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [

            # Build sdcard image with:
            # NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nix build .#nixosConfigurations.iso_aarch64.config.system.build.sdImage --impure
            # Note: host requires boot.bimfmt.emulatedSystems with aarch64-linux

            # Install with https://nix.dev/tutorials/nixos/installing-nixos-on-a-raspberry-pi
            # Needed to provide the system.build.sdImage target
            ("${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix")

            # Actual configuration
            # Build remotely with:
            # nixos-rebuild --target-host user@192.168.1.30 --flake path:.#iso_aarch64 --use-remote-sudo  switch
            ./rpi4/config.nix

            # HW support
            nixos-hardware.nixosModules.raspberry-pi-4
            
          ];
        };
      };
    };
}
