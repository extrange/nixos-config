# Overrides/patches. Should be kept to a minimum.
# To override home-manager modules, use home-manager.users.user.<attr>
{
  ...
}:
{
  nixpkgs.overlays = [
    (_final: _prev: {
    })
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];

}
