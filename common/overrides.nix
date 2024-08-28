# Overrides/patches. Should be kept to a minimum.
# To override home-manager modules, use home-manager.users.user.<attr>
{ lib, pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      compsize =
        let
          btrfs-progs' = pkgs.btrfs-progs.overrideAttrs (old: rec {
            pname = "btrfs-progs";
            version = "6.10";
            src = pkgs.fetchurl {
              url = "mirror://kernel/linux/kernel/people/kdave/btrfs-progs/btrfs-progs-v${version}.tar.xz";
              hash = "sha256-M4KoTj/P4f/eoHphqz9OhmZdOPo18fNFSNXfhnQj4N8=";
            };
          });

        in
        prev.compsize.overrideAttrs {
          buildInputs = [ btrfs-progs' ];
        };
    })
  ];
}
 