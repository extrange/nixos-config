# Overrides/patches. Should be kept to a minimum.
# To override home-manager modules, use home-manager.users.user.<attr>
{ lib, pkgs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      openldap = prev.openldap.overrideAttrs {
        doCheck = !prev.stdenv.hostPlatform.isi686; # https://github.com/NixOS/nixpkgs/issues/514113#issuecomment-4338976393
      };
      telegram-desktop =
        if lib.versionOlder prev.telegram-desktop.version "6.9.3" then
          (prev.telegram-desktop.override {
            unwrapped = prev.telegram-desktop.unwrapped.overrideAttrs (old: rec {
              version = "6.9.3";
              src = pkgs.fetchFromGitHub {
                owner = "telegramdesktop";
                repo = "tdesktop";
                rev = "v${version}";
                fetchSubmodules = true;
                hash = "sha256-QCGtESg+38lHWCFcsevHdc0kQ7LKJQmJjUJWszphah8=";
              };
              buildInputs = old.buildInputs ++ [ prev.minizip ];
            });
          })
        else
          prev.telegram-desktop;
    })
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];

}
