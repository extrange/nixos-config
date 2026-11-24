# Overrides/patches. Should be kept to a minimum.
# To override home-manager modules, use home-manager.users.user.<attr>
{
  ...
}:
{
  nixpkgs.overlays = [
    (final: prev: {
      # ZapZap uses Qt's GTK3 platform theme for its native file picker.
      # GTK's GSettings schemas are in a per-package gsettings-schemas
      # directory on NixOS, which isn't in XDG_DATA_DIRS for apps launched
      # from GNOME. Without it, opening the document picker aborts with
      # "Settings schema 'org.gtk.Settings.FileChooser' is not installed".
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
