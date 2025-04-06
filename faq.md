# FAQ

## Remote Error: `build of '.../xxx-linux-xxx-modules-shrunk/lib' is not in the Nix store

This error is caused by an outdated version of Nix installed on the remote host.

This can be updated as follows:

```bash
nix profile install nixpkgs#nix

# Note: The below command is outdated
nix-env --install --file '<nixpkgs>' --attr nix cacert -I nixpkgs=channel:nixpkgs-unstable
```

## Remote: `error: opening lock file '/nix/store/xxx-xxx.lock': Permission denied`

Temporary fix: `sudo chown -R user /nix`.

Permanent fix: This was (for me) caused by a `systemd` service running `nix-collect-garbage -d` as `root`. Adding `User=user` solved it.
