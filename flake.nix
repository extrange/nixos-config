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
        
        # Build ISO with:
        # NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nix build .#nixosConfigurations.iso_aarch64.config.system.build.sdImage --impure
        
        # Note: host requires boot.bimfmt.emulatedSystems with aarch64-linux
        # Install with https://nix.dev/tutorials/nixos/installing-nixos-on-a-raspberry-pi
        iso_aarch64 = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            ("${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix")
            ({ config, pkgs, ... }: {

              # Output as .img instead of .zst
              sdImage.compressImage = false;

              users = {
                users."user" = {
                  isNormalUser = true;
                  extraGroups = [ "networkmanager" "wheel" ];
                  initialHashedPassword = "$y$j9T$hWEXk9oQI3QFayjWyBZep0$xc3zAKoSt4jGvuxrcVMphXKM8b8wlcY61i/R99.pKQ6";

                  # Allow desktop to SSH in by default. Password login is still enabled.
                  openssh.authorizedKeys.keys = [
                    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyJ0LttXH9j3Ql7J1ccJbhLWdYhYn24qR6a8ur72hVi user@desktop"
                  ];

                  packages = with pkgs; [
                      moonlight-qt
                  ];
                };
              };

              services.openssh.enable = true;
            })
          ];
        };
      };
    };
}
