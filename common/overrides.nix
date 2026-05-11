# Overrides/patches. Should be kept to a minimum.
# To override home-manager modules, use home-manager.users.user.<attr>
{ lib, pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      openldap = prev.openldap.overrideAttrs {
        doCheck = !prev.stdenv.hostPlatform.isi686; # https://github.com/NixOS/nixpkgs/issues/514113#issuecomment-4338976393
      };
    })
  ];

  nixpkgs.config.permittedInsecurePackages = [
  ];

}
