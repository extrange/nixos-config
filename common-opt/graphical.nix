# Packages and options for graphical systems
{
  lib,
  ...
}:
with lib;
{
  options.graphical = mkEnableOption "Graphical applications and utilities";
  imports = [
    ./graphical/home.nix
    ./graphical/system.nix
  ];
}
