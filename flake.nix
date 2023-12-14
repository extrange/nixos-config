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

    let
      mkHost = hostname:
        nixpkgs.lib.nixosSystem {

          system = "x86_64-linux"; # Remove? set modularly

          modules =
            let
              host = n: ./hosts/${hostname}/${n}.nix;
              common = n: ./common/${n}.nix;
            in
            [
              # External modules
              sops-nix.nixosModules.sops
              home-manager.nixosModules.home-manager

              # Inputs, module options
              { config._module.args = { inherit hostname self; }; }
              {
                home-manager.extraSpecialArgs = {
                  inherit nnn;
                };
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
              }

              # System
              (common "system")
              (common "system-overrides")
              (host "system")
              (host "hardware-configuration")

              # Home
              {
                home-manager.users.user = { ... }: {
                  imports = [
                    (common "home")
                    (common "home-overrides")
                    (host "home")
                  ];
                };
              }
            ];
        };
    in
    {
      nixosConfigurations = with builtins; mapAttrs
        (hostname: _: mkHost hostname)
        (readDir ./hosts);
    };
}
