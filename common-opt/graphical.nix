# Packages and options for graphical systems
{ config, pkgs, lib, nnn, home-manager, ... }:
with lib;
{
  options.graphical = mkEnableOption "Graphical applications and utilities";
  imports = [
    ./graphical/home.nix
    ./graphical/system.nix
  ];
}
