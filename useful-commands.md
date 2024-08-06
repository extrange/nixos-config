# Useful Commands/Tools

Override SHA hash for a package (see also [Overriding]):

```nix
(azuredatastudio.overrideAttrs {
    src =
    let
        pname = "azuredatastudio";
        version = "1.48.1";
    in
    fetchurl {
        name = "${pname}-${version}.tar.gz";
        url = "https://azuredatastudio-update.azurewebsites.net/${version}/linux-x64/stable";
        sha256 = "sha256-bshkpcs1Ob7gdBWerjEWLJ/FUBjcwYb6Mv+cIIaxDWw=";
    };
})
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
