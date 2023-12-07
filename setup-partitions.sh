#!/usr/bin/env bash

set -euo pipefail

# https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if we are running as root
if [[ "$EUID" -ne 0 ]]; then
    printf "Please run as root\n"
    exit 1
fi

read -rp "Enter target disk (e.g. /dev/sda): " target

if [[ ! -b "$target" ]]; then
    printf "'%s' is not a valid block device, aborting\n" "$target"
    exit 1
fi

# Only accept disks
DEVICE_TYPE=$(lsblk -n -o TYPE "$target")

if [[ ! "$DEVICE_TYPE" =~ "disk" ]]; then
    printf "'%s' is not a disk, aborting\n" "$target"
    exit
fi

# Install git if not already available
if ! command -v git; then
    nix-env -f '<nixpkgs>' -iA git
fi

# User confirmation
printf "This script will setup a primary Btrfs partition with swap over a LUKS2 encrypted LVM.\n\n"
printf "${RED}All data in %s will be deleted!\n\n${NC}" "$target"
read -rp "To continue, enter YES in caps: " confirm && [[ $confirm == 'YES' ]] || exit 1

do_install() {
    # Script modified from https://gist.github.com/walkermalling/23cf138432aee9d36cf59ff5b63a2a58

    # Echo commands and print timestamp
    # https://stackoverflow.com/questions/50989501/bash-highlight-command-before-execution-set-x/62620480#62620480
    PS4='\033[1;34m$(date +%H:%M:%S):\033[0m '
    set -x

    # Create partition table
    parted -s "$target" -- mklabel gpt

    # Create boot partition
    # We leave 1MB of space at the start
    parted -s "$target" -- mkpart ESP fat32 1MiB 512MiB
    parted -s "$target" -- set 1 boot on

    # Create primary partition
    parted -s "$target" -- mkpart primary 512MiB 100%

    boot="${target}1"
    primary="${target}2"

    # Setup luks on primary partition
    cryptsetup luksFormat "$primary" --label=primary # will prompt for password
    cryptsetup luksOpen "$primary" crypted

    # LVM: Create physical volumes, volume groups and logical volumes
    pvcreate /dev/mapper/crypted
    vgcreate vg /dev/mapper/crypted
    lvcreate -L 8G -n swap vg # 8GB of swap
    lvcreate -l '100%FREE' -n nixos vg

    # Format disks
    mkfs.fat -F 32 -n boot "$boot"
    mkfs.btrfs -L nixos /dev/vg/nixos
    mkswap -L swap /dev/vg/swap

    # Create root Btrfs subvolume and mount for installation
    mount /dev/disk/by-label/nixos /mnt
    btrfs subvolume create /mnt/root
    umount /mnt
    mount /dev/disk/by-label/nixos -o subvol=root /mnt

    # Mount boot
    mkdir -p /mnt/boot && mount /dev/disk/by-label/boot /mnt/boot

    # Activate swap
    swapon /dev/vg/swap

    # Pull latest config, will be preserved on install
    git clone https://github.com/extrange/nixos-config /mnt/etc/nixos/nixos-config
    chown -R 1000 /mnt/etc/nixos/nixos-config

    # Generate config
    # TODO how to get script initially
    printf "Generating nixos configurations..."
    nixos-generate-config --root /mnt
    rm /mnt/etc/nixos/configuration.nix

    set +x

    clear
    lsblk
    cat <<EOF
Disk partitioning complete!

Next, move hardware-configuration.nix to the appropriate host directory, e.g.

sudo mv /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/nixos-config/hosts/<HOSTNAME>

Then, install nixos with:

sudo nixos-install --flake path:/mnt/etc/nixos/nixos-config#<HOSTNAME>

Finally, don't forget to push the new hardware configuration.
EOF
    return 0
}

do_install
