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
  };

  outputs = { nixpkgs, home-manager, sops-nix, ... }:

    let
      mkHost = hostname:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux"; # Remove? set modularly
          specialArgs = { inherit hostname; };
          modules = let file = n: ./hosts/${hostname}/${n}.nix; in [
            ./common/system.nix # Common config
            (file "system") # Machine specific config
            (file "hardware-configuration")
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.user = { ... }: {
                imports = [
                  ./common/home.nix
                  (file "home")
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
