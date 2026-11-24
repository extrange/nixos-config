# Overrides/patches. Should be kept to a minimum.
# To override home-manager modules, use home-manager.users.user.<attr>
{
  ...
}:
{
  nixpkgs.overlays = [
    (final: prev: {
      # https://github.com/NixOS/nixpkgs/issues/592053
      zapzap = prev.zapzap.overrideAttrs (old: {
        preFixup = (old.preFixup or "") + ''
          makeWrapperArgs+=(--prefix XDG_DATA_DIRS : "${final.gtk3}/share/gsettings-schemas/${final.gtk3.name}")
        '';
      });
    })
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];

}
