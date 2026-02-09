# My NixOS Configuration

![screenshot](./screenshot.jpg)

- [Useful Commands]
- [Server]

## Hosts

| Name         | Description                                                    |
| ------------ | -------------------------------------------------------------- |
| server (TBC) | Runs my homelab and hosts the bulk of my data.                 |
| zephyr       | Runs Windows VM with GPU passthrough for gaming/video editing. |
| io           | Logging and uptime monitoring.                                 |
| desktop      | Portal device                                                  |
| laptop       | Portal device                                                  |

## Setting up a new host

- Create its config (and optionally [disko]'s config) under `hosts/`
- Generate the host's user's SSH key and place it in `server`'s `~/keys`. This key is used to encrypt/decrypt sops secrets in `secrets.yaml`.
- Get the `age` key from the SSH public key: `ssh-keygen -y -f path/to/public/key | ssh-to-age`
- Add that key to `.sops.yaml`. Then, from another host with its key added prior, add the new host's key to `secrets.yaml` with `SOPS_AGE_KEY=$(ssh-to-age -private-key -i ~/.ssh/id_ed25519) sops updatekeys secrets.yaml`
- (optional) If this host should be allowed to SSH into my servers, add that SSH key to the common authorized SSH keys.
- Deploy via [nixos-anywhere]
- SSH into the host as `root` and copy over the host's user's SSH key.
- Add the machine's SSH host key to the common known keys (obtain with `ssh-keyscan -t ed25519 hostname`)

**Post Install**

- Setup logins (these can't be declaratively set)
  - Tailscale
  - Telegram
  - Whatsapp
  - GSConnect pairing
- (if necessary) Update DHCP reservations in router
- (libvirt) setup network auto-start with `sudo virsh net-autostart --network default`

## Resources

- Dotfiles: [dmadisetti], [Electrostasy], [reckenrode]
- Hyprland configs: [yurihikari], [Waayway]
- [Comparison of `git-crypt`, `agenix` and `sops-nix`][secrets]

[secrets]: https://lgug2z.com/articles/handling-secrets-in-nixos-an-overview/
[Waayway]: https://github.com/Waayway/hyprland-waayway
[yurihikari]: https://github.com/yurihikari/garuda-sway-config
[electrostasy]: https://github.com/Electrostasy/dots
[reckenrode]: https://github.com/reckenrode/nixos-configs
[dmadisetti]: https://github.com/dmadisetti/.dots
[Useful Commands]: useful-commands.md
[Server]: hosts/server/server.md
[nixos-anywhere]: https://github.com/nix-community/nixos-anywhere
[disko]: https://github.com/nix-community/disko