# Server Configuration

Some notes about my server configuration (as I'll be moving it to NixOS soon).

## Drive configuration

TODO: Move these to disko.

Each volume/dataset may have:

- Snapshots
- Backups (6-monthly)
- Scrubs (monthly)

### ZFS

- Dataset properties: `atime=off`, `compression=zstd-3`

| Pool    | Drives         | Scrub |
| ------- | -------------- | :---: |
| storage | 4x HDD, RAIDZ2 |  ✅   |
| vm-data | 2x HDD, RAID1  |  ✅   |

| Dataset                | Snaps | Backup |
| ---------------------- | :---: | :----: |
| storage/data           |  ✅   |   ✅   |
| vm-data/windows-gaming |  ✅   |        |

_Note: RAIDZ [should not][raidz-database] be used with databases._

### Btrfs

Mount options: `noatime,compress=zstd`

| Volume | Drives         | Scrub |
| ------ | -------------- | :---: |
| /      | 2x SSD, mirror |  ✅   |

| Subvolume      | Snaps | Backup |
| -------------- | :---: | :----: |
| root           |  ✅   |   ✅   |
| server         |  ✅   |   ✅   |
| vm             |  ✅   |        |
| var/log        |       |        |
| var/lib/docker |       |        |
| nix            |       |        |

#### Direct writes and checksum errors

Btrfs has issues syncing the checksum with the written data when direct writes ([O_DIRECT]) are used. Some sources of direct writes are libvirt's `cache=none` and fio's `direct=1` flags.

For this reason, in libvirt, avoid using `cache=none` for disks.

Further reading:

- [Cache modes in libvirt]
- [Cache terminology]
- [Btrfs man pages on direct writes][btrfs-checksum]
- [Btrfs storage (Proxmox)][proxmox-btrfs]

## ZFS Backup + Scrub Command

Backup the server's snapshots to a local drive, then scrub it.

The pool's root dataset is configured with `compression=zstd-3` and `atime=off`.

```bash
sudo bash -c "
  syncoid \
    --delete-target-snapshots \
    --sshkey ~/.ssh/id_ed25519 \
    --sshport 39483 \
    server:storage/data archive/storage/data && \
  zpool scrub -w archive && \
  zpool status archive
"
```

_Note: We don't preserve properties (`--preserve-properties`) because we don't want to preserve the `mountpoint` property._

[O_DIRECT]: https://man7.org/linux/man-pages/man2/open.2.html
[btrfs-checksum]: https://btrfs.readthedocs.io/en/latest/btrfs-man5.html#checksum-algorithms
[proxmox-btrfs]: https://pve.proxmox.com/wiki/Storage:_BTRFS
[raidz-database]: https://old.reddit.com/r/zfs/comments/shwtbm/deleted_by_user/hvda4wk/
[Cache modes in libvirt]: https://pve.proxmox.com/wiki/Performance_Tweaks#Disk_Cache
[Cache terminology]: https://forum.huawei.com/enterprise/intl/en/thread/differences-between-disk-cache-write-through-and-write-back/667215004455288832?blogId=667215004455288832
