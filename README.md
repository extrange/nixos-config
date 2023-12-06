# My NixOS Configuration

Each host has 3 files:

- home.nix
- system.nix
- hardware-configuration.nix

> [!IMPORTANT]
> Before installing anything, you will need to back up your existing configuration:
>
> - `~/.ssh` keys
> - Firefox profile directory
> - `/etc/fstab`
> - `nm-cli` connections (if applicable)
> - VM images (if applicable)

## Post-install

- git clone `nixos-config`
- Logins:
  - Tailscale
  - Telegram
  - Whatsapp
- Syncthing folders, add to server
- Obsidian select vault
- Nautilus bookmarks
- Git?

## Notes

`nixos-rebuild switch --flake .#hostname` will not allow access to untracked files. To [work around] this, do `nixos-rebuild switch --flake path:.#hostname` instead.

[work around]: https://discourse.nixos.org/t/dirty-nixos-rebuild-build-flake-issues/30078/2
