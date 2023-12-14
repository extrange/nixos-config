# Overrides/patches. Should be kept to a minimum.
{ config, pkgs, lib, nnn, ... }:

{
  # Temporarily upgrade vscode
  home.packages = with pkgs; [
    (vscode.overrideAttrs
      (finalAttrs: prevAttrs: rec {
        version = "1.85.1";
        plat = "linux-x64";
        src = pkgs.fetchurl {
          name = "VSCode_${version}_${plat}.tar.gz";
          url = "https://update.code.visualstudio.com/${version}/${plat}/stable";
          sha256 = "sha256-AWadaeVnpSkDNrHS97Lw8YFunXCZAEuBom+PQO4Xyfw=";
        };
      })
    )
  ];

}

