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
  };

  outputs = { nixpkgs, home-manager, sops-nix, nnn, self, ... }:
    with builtins;

    let
      hasSuffix = nixpkgs.lib.hasSuffix;

      join = nixpkgs.lib.path.subpath.join;

      getNixFilesInDir = d: map (p: join [ d p ]) (filter (n: hasSuffix ".nix" n) (attrNames (readDir d)));

      mkHost = hostname: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          { config._module.args = { inherit hostname self nnn; }; }
        ]
        ++ (getNixFilesInDir ./common)
        ++ (getNixFilesInDir ./common-opt)
        ++ (getNixFilesInDir ./hosts/${hostname});
      };
    in
    {
      nixosConfigurations = (mapAttrs
        (hostname: _: mkHost hostname)
        (readDir ./hosts)) // {

        # Build ISO with
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
      };
    };
}
