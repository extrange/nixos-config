# My NixOS Configuration

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

- git credentials - gh?
- phase out startingpoint
- nfs mounts
- script to install nixos from commandline (and try myself also)
- desktop scaling, monitor position, don't sleep/dim/lock
- clean up tailscale old devices

## Stuff to configure manually after install

- update `hardware-configuration.nix` with `nixos-generate-config`
- Telegram login
- Git?
- Syncthing folders, add to server
- Tailscale login

## Notes

`nixos-rebuild switch --flake .#hostname` will not allow access untracked files. To [work around] this, do `nixos-rebuild switch --flake path:.#hostname` instead.

[work around]: https://discourse.nixos.org/t/dirty-nixos-rebuild-build-flake-issues/30078/2
