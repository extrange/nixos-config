# Overrides/patches. Should be kept to a minimum.
{...}:
{
  # Workaround for Obsidian
  # https://github.com/NixOS/nixpkgs/issues/273611
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];
}
