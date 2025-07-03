# Overrides/patches. Should be kept to a minimum.
# To override home-manager modules, use home-manager.users.user.<attr>
{ lib, pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
    })
  ];
}
