# Overrides/patches. Should be kept to a minimum.
# To override home-manager modules, use home-manager.users.user.<attr>
{ lib, pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
    })
  ];

  # Darktable
  # https://github.com/NixOS/nixpkgs/issues/429268
  nixpkgs.config.permittedInsecurePackages = [
    "libsoup-2.74.3"
  ];

}
