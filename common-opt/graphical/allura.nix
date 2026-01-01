{ stdenvNoCC }:

# Attributes: https://nixos.org/manual/nixpkgs/stable/#ssec-stdenv-attributes
stdenvNoCC.mkDerivation {
  pname = "allura";
  version = "main";

  src = builtins.fetchurl {
    url = "https://github.com/google/fonts/raw/main/ofl/allura/Allura-Regular.ttf";
    sha256 = "1ijcq6x62iiwnbi74ywkpx1ljca0iyhqx2zzqkgw0cjqa4p2n54w";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype
    cp $src $out/share/fonts/truetype

    runHook postInstall
  '';
}
