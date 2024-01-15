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
      mkHost = hostname:
        nixpkgs.lib.nixosSystem {

          system = "x86_64-linux";

          modules =
            let
              getHostConfig = n: ./hosts/${hostname}/${n}.nix;
              commonSystemConfig = filter (n:  ".nix" n) (attrNames (readDir ./common));
              commonHomeConfig = 2;
            in
            [
              # External modules
              sops-nix.nixosModules.sops
              home-manager.nixosModules.home-manager

              # Inputs, module options
              { config._module.args = { inherit hostname self; }; }

              # Host-specific
              (getHostConfig "system")
              (getHostConfig "hardware-configuration")

              # Home Manager
              {
                home-manager = {
                  users.user = { ... }: {
                    imports = [ (getHostConfig "home") ] ++ commonHomeConfig;
                  };
                  extraSpecialArgs = { inherit nnn; };
                  useGlobalPkgs = true;
                  useUserPackages = true;
                };
              }
            ] ++ commonSystemConfig;
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
