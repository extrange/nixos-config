{
  description = "My NixOS Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
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

  outputs =
    {
      nixpkgs,
      nixpkgs-stable,
      home-manager,
      sops-nix,
      self,
      ...
    }@inputs:
    with builtins;
    with nixpkgs.lib;

    let
      getNixFilesInDir = d: map (p: d + "/${p}") (filter (n: hasSuffix ".nix" n) (attrNames (readDir d)));

      mkHost =
        hostname:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            {
              _module.args = inputs // {
                inherit hostname;
                pkgs-stable = import nixpkgs-stable {
                  system = "x86_64-linux";
                  config.allowUnfree = true;
                };
              };
            }
          ]
          ++ (getNixFilesInDir ./common)
          ++ (getNixFilesInDir ./common-opt)
          ++ (getNixFilesInDir ./hosts/${hostname});
        };

    in
    {
      # This builds all derivations here on `nix flake check`.
      # https://github.com/NixOS/nix/issues/7165
      checks =
        let
          # Shape:
          # [
          #   {x86_64-linux: {name = desktop; value = desktopConfig;}}
          #   {x86_64-linux: {name = laptop; value = laptopConfig;}}
          #   ...
          # ]
          systems = mapAttrsToList (
            hostname: type:
            let
              config = self.nixosConfigurations.${hostname}.config.system.build.toplevel;
              system = config.system;
            in
            {
              ${system} = {
                name = hostname;
                value = config;
              };
            }
          ) (readDir ./hosts);
        in
        # Shape:
        # {x86_64-linux = {desktop = desktopConfig; laptop: laptopConfig;}}
        zipAttrsWith (system: listToAttrs) systems;

      nixosConfigurations =
        (mapAttrs (hostname: _: mkHost hostname)
          # Get hostnames by reading folder name in hosts/
          (readDir ./hosts)
        )
        // {

          # ISO installer image with USB wifi driver support
          # Build with:
          # nix build .#nixosConfigurations.iso-wifi.config.system.build.isoImage
          iso-wifi = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
              # Add rtl8821cu wifi driver
              (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
              (
                {
                  config,
                  ...
                }:
                {
                  boot.extraModulePackages = with config.boot.kernelPackages; [
                    rtl8821cu
                  ];
                }
              )
            ];
          };
        };
    };
}
