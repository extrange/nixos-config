# Server Configuration

Some notes about my server configuration (as I'll be moving it to NixOS soon).

## Drive configuration

All with compression turned on (zstd).

| Mount Point           | Snaps | Setup      | Use                      |
| --------------------- | ----- | ---------- | ------------------------ |
| `/mnt/storage`        | Yes   | HDD, RAIDZ | File storage             |
| `/`                   | Yes   | SSD, RAID1 | OS, VM OS, server, repos |
| `/dev/zvol/vm-data/*` | No    | HDD, RAID1 | VM storage (as zvols)    |

Subvolumes on `/` (all top-level):

| Path           | Description                            |
| -------------- | -------------------------------------- |
| var/log        | Don't snapshot syslogs                 |
| var/lib/docker | Don't snapshot anything Docker-related |
| nix            | Nix                                    |
| vm             | VM OS image                            |
| server         | Server docker containers               |

Barring those exceptions, the rest of `/` is snapshotted.

Note: RAIDZ [should not][raidz-database] be used with databases.

## Btrfs direct writes and checksum errors

Btrfs has issues syncing the checksum with the written data when direct writes ([O_DIRECT]) are used. Some sources of direct writes are libvirt's `cache=none` and fio's `direct=1` flags.

For this reason, in libvirt, avoid using `cache=none` for disks.

Resources:

- [Cache modes in libvirt]
- [Cache terminology]
- [Btrfs man pages on direct writes][btrfs-checksum]
- [Btrfs storage (Proxmox)][proxmox-btrfs]

## ZFS Backup + Scrub

```sh
sudo syncoid --preserve-properties --sshkey ~/.ssh/id_ed25519 --sshport 39483 server:storage/data archive/storage/data && \
ssh root@server 'zfs zpool scrub -w storage && zpool status storage'
```

[O_DIRECT]: https://man7.org/linux/man-pages/man2/open.2.html
[btrfs-checksum]: https://btrfs.readthedocs.io/en/latest/btrfs-man5.html#checksum-algorithms
[proxmox-btrfs]: https://pve.proxmox.com/wiki/Storage:_BTRFS
[raidz-database]: https://old.reddit.com/r/zfs/comments/shwtbm/deleted_by_user/hvda4wk/
[Cache modes in libvirt]: https://pve.proxmox.com/wiki/Performance_Tweaks#Disk_Cache
[Cache terminology]: https://forum.huawei.com/enterprise/intl/en/thread/differences-between-disk-cache-write-through-and-write-back/667215004455288832?blogId=667215004455288832
