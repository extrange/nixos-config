# Server Configuration

Some notes about my server configuration (as I'll be moving it to NixOS soon).

## Drive configuration

TODO: Move these to disko.

### ZFS

Dataset properties: `atime=off`, `compression=zstd-3`

| Dataset                | Storage       | Snaps | Backup |
| ---------------------- | ------------- | ----- | ------ |
| storage/data           | 4x HDD, RAIDZ | Yes   | Yes    |
| storage/windows-gaming | 2x HDD, RAID1 | Yes   | No     |

Note: RAIDZ [should not][raidz-database] be used with databases.

### Btrfs

Mount options: `noatime,compress=zstd`

All on 2x SSD, RAID1 (mirror).

| Subvolume      | Snaps | Backup |
| -------------- | ----- | ------ |
| root           | Yes   | Yes    |
| server         | Yes   | Yes    |
| vm             | Yes   | No     |
| var/log        | No    | No     |
| var/lib/docker | No    | No     |
| nix            | No    | No     |

#### Direct writes and checksum errors

Btrfs has issues syncing the checksum with the written data when direct writes ([O_DIRECT]) are used. Some sources of direct writes are libvirt's `cache=none` and fio's `direct=1` flags.

For this reason, in libvirt, avoid using `cache=none` for disks.

Further reading:

- [Cache modes in libvirt]
- [Cache terminology]
- [Btrfs man pages on direct writes][btrfs-checksum]
- [Btrfs storage (Proxmox)][proxmox-btrfs]

## ZFS Backup + Scrub Command

The pool dataset is configured with `compression=zstd-3` and `atime=off`.

```sh
sudo syncoid \
--delete-target-snapshots \
--sshkey ~/.ssh/id_ed25519 \
--sshport 39483 \
server:storage/data archive/storage/data && \
ssh root@server 'zfs zpool scrub -w storage && zpool status storage'
```

_Note: We don't preserve properties (`--preserve-properties`) because we don't want to preserve the `mountpoint` property._

[O_DIRECT]: https://man7.org/linux/man-pages/man2/open.2.html
[btrfs-checksum]: https://btrfs.readthedocs.io/en/latest/btrfs-man5.html#checksum-algorithms
[proxmox-btrfs]: https://pve.proxmox.com/wiki/Storage:_BTRFS
[raidz-database]: https://old.reddit.com/r/zfs/comments/shwtbm/deleted_by_user/hvda4wk/
[Cache modes in libvirt]: https://pve.proxmox.com/wiki/Performance_Tweaks#Disk_Cache
[Cache terminology]: https://forum.huawei.com/enterprise/intl/en/thread/differences-between-disk-cache-write-through-and-write-back/667215004455288832?blogId=667215004455288832
