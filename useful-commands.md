# Useful Commands/Tools

Override SHA hash for a package (see also [Overriding]):

```nix
(azuredatastudio.overrideAttrs
  rec {
    pname = "azuredatastudio";
    version = "1.48.1";
    src = fetchurl {
      name = "${pname}-${version}.tar.gz";
      url = "https://download.microsoft.com/download/d/6/f/d6f2673f-5240-4605-8e7d-5b6c49d188e8/azuredatastudio-linux-1.48.1.tar.gz";
      sha256 = "sha256-JDNdMy0Wk6v2pMKS+NzSbsrffaEG2IneZO+K9pBFX48=";
    };
  }
)
```

The same thing, but as an [overlay]:

```nix
# This should be imported as a module
{ lib, pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      # Add version of keyd with laptop hotkey support
      keyd = with pkgs; prev.keyd.overrideAttrs {
        version = "custom";
        src = fetchFromGitHub {
          owner = "rvaiya";
          repo = "keyd";
          rev = "5832c750be5bbfa83c0490bfe1068b92b19688f4";
          hash = "sha256-7wRyurJk7rsIXCcAe3XlGsa9SjWpDieXD7X/V6wilFM=";
        };
        makeFlags = [ "DESTDIR=$(out)" "PREFIX=''" ];
        postPatch = ''
        '';
        postInstall = ''
          rm -rf $out/etc
        '';
      };
    })
  ];
}
```

[Use a package from a specific version of nixpkgs][specific-package-version]:

```nix
# flake.nix

{
  description = "Configuration flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11-small";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable-small";
  };

  outputs = inputs@{self, nixpkgs, nixpkgs-unstable, ... }: {
    nixosConfigurations = {
      virtualbox-nixos = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {
          # Add pkgs-unstable as an input to your modules
          pkgs-unstable = import nixpkgs-unstable {
            system = system;
            config.allowUnfree = true;
          };
        };
        modules = [
          ./configuration.nix
       ];
      };
    };
  };
}

# configuration.nix

users.users.myusername = {
  packages =
    let
      stable =  with pkgs; [
        # ...
      ];
      unstable = with pkgs-unstable; [
        # You can use the unstable version of packages here
        k9s
      ];
    in stable ++ unstable;
};
```

Evaluate the value of a configuration option:

```bash
nix eval path:.<path-to-expression>

# E.g.
nix eval path:.#nixosConfigurations.rpi4.config.networking.hostName

# Output:
"laptop"
```

[Overriding]: https://ryantm.github.io/nixpkgs/using/overrides/
[overlay]: https://nixos.wiki/wiki/Overlays#Examples_of_overlays
[specific-package-version]: https://old.reddit.com/r/NixOS/comments/1b08hqn/can_flakes_pin_specific_versions_of_individual/
