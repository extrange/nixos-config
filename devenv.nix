{
  pkgs,
  ...
}:

{
  packages = with pkgs; [
    git
    ssh-to-age
    sops
  ];
  languages.nix.enable = true;
  languages.nix.lsp.enable = true;

  git-hooks.hooks = {
    trim-trailing-whitespace.enable = true;
    end-of-file-fixer.enable = true;
    check-yaml.enable = true; # Does not validate schema
    check-added-large-files.enable = true;
    check-case-conflicts.enable = true;

    # blackbox_exporter has no published JSON schema, so let the exporter
    # validate its own config instead.
    blackbox-config = {
      enable = true;
      name = "blackbox_exporter config";
      description = "Validate blackbox_exporter modules with --config.check";
      language = "system";
      files = "blackbox\\.ya?ml$";
      entry = "${pkgs.bash}/bin/bash -c 'for f in \"$@\"; do ${pkgs.prometheus-blackbox-exporter}/bin/blackbox_exporter --config.check --config.file \"$f\" || exit 1; done' --";
    };

    # Nix
    deadnix.enable = true;
    nixfmt.enable = true;
    # statix.enable = true; # Too noisy
  };
}
