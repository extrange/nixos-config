# Useful Commands/Tools

## Setup formatting on a remote

```bash
nix profile install github:nixos/nixd
nix profile install github:nixos/nixfmt
```

Modify the remote's `settings.json` appropriately.

## Flakes

`#` is used to access the outputs of a flake, when referenced from the command line.

E.g. `nixos-rebuild switch --flake path:.#nixosConfigurations`.

## Packaging

[Tutorial][package-tutorial]

## Progress Bar Explanation

See [this][nix-progress].

## Commands

[nixpkgs.lib functions](https://teu5us.github.io/nix-lib.html)

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

Allow insecure packages temporarily:

```nix
# Workaround for Obsidian
# https://github.com/NixOS/nixpkgs/issues/273611
nixpkgs.config.permittedInsecurePackages = lib.optional (pkgs.obsidian.version == "1.5.3") "electron-25.9.0";
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

Run a specific version of a package with `nix shell`:

```bash
export NIXPKGS_ALLOW_UNFREE=1
nix shell nixpkgs/dd613136ee91f67e5dba3f3f41ac99ae89c5406b#vscode-fhs --impure
# You can find the nixpkgs revision using https://www.nixhub.io
```

Evaluate the value of a configuration option:

```bash
nix eval path:.<path-to-expression>

# E.g.
nix eval path:.#nixosConfigurations.rpi4.config.networking.hostName

# Output:
"laptop"
```

Evaluate the value of a flake, applying a function:

```bash
nix eval path:.<path-to-expression> -apply <function>

# E.g.
nix eval path:.#nixosConfigurations.desktop.config.system --apply builtins.attrNames

# Output:
[ "activatable", "activatableSystemBuilderCommands", ...]

# Another attribute on the flake output
nix eval path:.#checks --apply builtins.attrNames

# Output:
[ "desktop" "family-server" ...]
```

Load a flake into the repl (more info on [nix repl]):

```bash
nix repl --expr '(builtins.getFlake "/home/user/nixos-config")'
# Tab completion will work subsequently on attributes of the flake, e.g. inputs/outputs
```

`nixd` VSCode configuration, which loads all possible options:

```json
"nix.serverSettings": {
  "nixd": {
    "formatting": {
      "command": [
        "nixfmt"
      ]
    },
    "nixpkgs": {
        // An alternative is absolute path, but will require different configuration on the server.
        // "expr": "import (builtins.getFlake \"/home/user/nixos-config\").inputs.nixpkgs { }"
        "expr": "import (builtins.getFlake \"github:extrange/nixos-config\").inputs.nixpkgs { }"
    },
    "options": {
        "all": {
            "expr": "(builtins.getFlake \"github:extrange/nixos-config\").nixosConfigurations.laptop.options"
        },
    }
  }
},
```

Build a flake and discard the result (useful on a remote system)

```bash
nix build path:.#nixosConfigurations.<hostname>.config.system.build.toplevel
```

Check a flake (with uncommitted changes):

```bash
nix flake check path:.
```

Build flake locally without using remote builders:

```bash
sudo nixos-rebuild switch --flake . --builders '' --max-jobs 4
```

[Overriding]: https://ryantm.github.io/nixpkgs/using/overrides/
[overlay]: https://nixos.wiki/wiki/Overlays#Examples_of_overlays
[specific-package-version]: https://old.reddit.com/r/NixOS/comments/1b08hqn/can_flakes_pin_specific_versions_of_individual/
[nix-progress]: https://github.com/NixOS/nix/issues/3352
[nix repl]: https://github.com/justinwoo/nix-shorts/blob/master/posts/inspecting-values-with-repl.md
[package-tutorial]: https://nix-tutorial.gitlabpages.inria.fr/nix-tutorial/first-package.html
