# Overrides/patches. Should be kept to a minimum.
# To override home-manager modules, use home-manager.users.user.<attr>
{ lib, pkgs, ... }:
{
  # Workaround for Obsidian
  # https://github.com/NixOS/nixpkgs/issues/273611
  nixpkgs.config.permittedInsecurePackages = lib.optional (pkgs.obsidian.version == "1.5.3") "electron-25.9.0";

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
 