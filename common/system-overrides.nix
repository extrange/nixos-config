# Overrides/patches. Should be kept to a minimum.
{ lib, pkgs, ... }:
{
  # Workaround for Obsidian
  # https://github.com/NixOS/nixpkgs/issues/273611
  nixpkgs.config.permittedInsecurePackages = lib.optional (pkgs.obsidian.version == "1.4.16") "electron-25.9.0";
}
