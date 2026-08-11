{
  pkgs,
  ...
}:

{
  packages = [ pkgs.git ];
  languages.nix.enable = true;
  languages.nix.lsp.enable = true;

  git-hooks.hooks = {
    trim-trailing-whitespace.enable = true;
    end-of-file-fixer.enable = true;
    check-yaml.enable = true; # Does not validate schema
    check-added-large-files.enable = true;
    check-case-conflicts.enable = true;

    # Nix
    deadnix.enable = true;
    nixfmt.enable = true;
    # statix.enable = true; # Too noisy
  };
}
