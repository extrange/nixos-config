# Overrides/patches. Should be kept to a minimum.
# To override home-manager modules, use home-manager.users.user.<attr>
{ lib, pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
    })
  ];

  nixpkgs.config.permittedInsecurePackages = [
    # Darktable
    # https://github.com/NixOS/nixpkgs/issues/429268
    "libsoup-2.74.3"

    # Jellyfin
    "qtwebengine-5.15.19"
  ];

}
