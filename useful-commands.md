# Useful Commands/Tools For Flakes

## Accessing Outputs

`#` is used to access the outputs of a flake, when referenced from the command line.

E.g. `nixos-rebuild switch --flake path:.#nixosConfigurations`.

## Dev Shells

With the following `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

      in
      with pkgs;
      {
        devShells.default = mkShell {
          buildInputs = [ uv ];
        };
      }
    );
}
```

You can run `nix develop` to enter a [Nix development environment] (actually a build environment) which has `uv` installed.

Alternatively, you could do this with `nix shell nixpkgs#uv`.

However, with `uv`, as it downloads Python binaries (which will [not work][uv-nix] on Nix as they expect a traditional filesystem layout), you need to use a [FHS environment]:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        fhs = pkgs.buildFHSEnv {
          name = "fhs-shell";
          targetPkgs = pkgs: [
            pkgs.uv
          ];
        };
      in
      {
        devShells.default = fhs.env;
      }
    );
}
```

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

# Alternatively
nix repl --expr "builtins.getFlake \"$PWD\""
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

Update a host remotely:

```bash
# Note: you need to ssh as root on the host
nixos-rebuild switch --flake path:. --target-host root@192.168.1.135
```

Install packages with `nix profile`:

```bash
# E.g., setup formatting on a remote
nix profile install nixpkgs/nixpkgs-unstable#nixd
nix profile install nixpkgs/nixpkgs-unstable#nixfmt-rfc-style
```

[Overriding]: https://ryantm.github.io/nixpkgs/using/overrides/
[overlay]: https://nixos.wiki/wiki/Overlays#Examples_of_overlays
[specific-package-version]: https://old.reddit.com/r/NixOS/comments/1b08hqn/can_flakes_pin_specific_versions_of_individual/
[nix-progress]: https://github.com/NixOS/nix/issues/3352
[nix repl]: https://github.com/justinwoo/nix-shorts/blob/master/posts/inspecting-values-with-repl.md
[package-tutorial]: https://nix-tutorial.gitlabpages.inria.fr/nix-tutorial/first-package.html
[Nix development environment]: https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-develop
[uv-nix]: https://old.reddit.com/r/NixOS/comments/1fv4hyg/anyone_using_python_uv_on_nixos/
[FHS environment]: https://www.alexghr.me/blog/til-nix-flake-fhs/
