# My NixOS Configuration

Each host has 3 files:

- home.nix
- config.nix
- hardware-configuration.nix

> [!IMPORTANT]
> Before installing anything, you will need to back up your existing configuration:
>
> - `~/.ssh` keys
> - Firefox profile
> - `nm-cli` connections
> - `/etc/fstab`
> - Syncthing `.config`
> - VM images

## Todo

- git credentials - gcm + passphrase in git config?
- phase out startingpoint
- script to install nixos from commandline (and try myself also)
- DND on timer

## Stuff to configure manually after install

- update `hardware-configuration.nix` with `nixos-generate-config`
- Telegram login
- Git?
- Syncthing folders, add to server
- Tailscale login
- Obsidian select vault
- Nautilus bookmarks
- whatsapp login

## Notes

`nixos-rebuild switch --flake .#hostname` will not allow access untracked files. To [work around] this, do `nixos-rebuild switch --flake path:.#hostname` instead.

[work around]: https://discourse.nixos.org/t/dirty-nixos-rebuild-build-flake-issues/30078/2
