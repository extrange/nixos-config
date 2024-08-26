{
  description = "My NixOS Config";

  nixConfig = {
    extra-substituters = [ "https://raspberry-pi-nix.cachix.org" ];
    extra-trusted-public-keys = [
      "raspberry-pi-nix.cachix.org-1:WmV2rdSangxW0rZjY/tBvBDSaNFQ3DyEQsVw8EvHn9o="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    raspberry-pi-nix.url = "github:tstat/raspberry-pi-nix";
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

  # TODO migrate to using @inputs instead
  outputs = { nixpkgs, nixpkgs-stable, home-manager, sops-nix, nnn, self, ... }:
    with builtins;

    let
      hasSuffix = nixpkgs.lib.hasSuffix;

      getNixFilesInDir = d: map (p: d + "/${p}") (filter (n: hasSuffix ".nix" n) (attrNames (readDir d)));

      mkHost = hostname: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            _module.args = {
              inherit hostname self nnn home-manager nixpkgs-stable; pkgs-stable = import nixpkgs-stable {
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
      checks = {
        x86_64-linux = {
          name = self.nixosConfigurations.desktop.config.system.build.toplevel;
        }; 
      };
      nixosConfigurations = (mapAttrs
        (hostname: _: mkHost hostname)
        # Get hostnames by reading folder name in hosts/
        (readDir ./hosts)) // {

        # ISO installer image with USB wifi driver support
        # Build with:
        # nix build .#nixosConfigurations.iso-wifi.config.system.build.isoImage
        iso-wifi = nixpkgs.lib.nixosSystem {
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
        # rpi4 = nixpkgs.lib.nixosSystem {
        #   system = "aarch64-linux";
        #   modules = [

        #     sops-nix.nixosModules.sops
        #     ./common-opt/wifi.nix

        #     # https://github.com/nix-community/raspberry-pi-nix
        #     raspberry-pi-nix.nixosModules.raspberry-pi

        #     ./rpi4/config.nix

        #   ];
        # };
      };
    };
}
