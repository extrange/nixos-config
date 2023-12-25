#!/usr/bin/env bash

clear

# https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
RED='\033[0;31m'
NC='\033[0m' # No Color

nixos_config_dir=/mnt/home/user/nixos-config
KNOWN_HOSTS="ssh.nicholaslyz.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAm3fEcDvIM7cFCjB3vzBb4YctOGMpjf8X3IxRl5HhjV"

# Check if we are running as root
if [[ "$EUID" -ne 0 ]]; then
    printf "Please run as root\n"
    exit 1
fi

# User confirmation
printf "This script will setup a primary Btrfs partition over a LUKS2 encrypted LVM.\n\n"
printf "${RED}All data in %s will be deleted!${NC}\n\n" "$target"
printf "Press \033[1mCtrl+C\033[0m now to abort this script, or wait 5s for the installation to continue.\n\n"
sleep 5

printf "Available disks:\n\n%s\n\n" "$(lsblk -o NAME,SIZE,MODEL,TYPE | grep -Ei 'disk|type')"

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

read -rp "Enter target hostname (e.g. desktop): " hostname

do_install() {
    set -euo pipefail

    # Script modified from https://gist.github.com/walkermalling/23cf138432aee9d36cf59ff5b63a2a58

    # Install commandline dependencies
    printf "Installing git and other tools...\n"
    nix-env -f '<nixpkgs>' -iA git yq-go ssh-to-age sops >/dev/null

    # Clone git repo (required for boot key)
    mkdir -p /tmp/nixos-config
    git clone https://github.com/extrange/nixos-config /tmp/nixos-config

    # Copy ssh keys to temp dir before install (used to decrypt boot key)
    SSH_KEYFILE_TEMP=/tmp/id_ed25519
    KNOWN_HOSTS_FILE=/tmp/known_hosts
    echo "$KNOWN_HOSTS" >"$KNOWN_HOSTS_FILE"
    scp -P 39483 -o UserKnownHostsFile="$KNOWN_HOSTS_FILE" user@ssh.nicholaslyz.com:/home/user/keys/"$hostname" "$SSH_KEYFILE_TEMP"

    # Create partition table
    parted -s "$target" -- mklabel gpt

    # Create boot partition
    # We leave 1MB of space at the start
    parted -s "$target" -- mkpart ESP fat32 1MiB 512MiB
    parted -s "$target" -- set 1 boot on

    # Create primary partition
    parted -s "$target" -- mkpart primary 512MiB 100%

    boot=$(lsblk "${target}" -lno path | sed -n 2p)
    primary=$(lsblk "${target}" -lno path | sed -n 3p)

    # Setup luks on primary partition
    (
        export SOPS_AGE_KEY
        SOPS_AGE_KEY=$(ssh-to-age -private-key -i "$SSH_KEYFILE_TEMP")
        BOOT_KEY=$(sops -d /tmp/nixos-config/secrets.yaml | yq '.boot')
        echo -n "$BOOT_KEY" | cryptsetup luksFormat --label=primary "$primary" -
        echo -n "$BOOT_KEY" | cryptsetup luksOpen "$primary" crypted -
    )

    # LVM: Create physical volumes, volume groups and logical volumes
    pvcreate /dev/mapper/crypted
    vgcreate vg /dev/mapper/crypted
    lvcreate -l '100%FREE' -n nixos vg

    # Format disks
    mkfs.fat -F 32 -n boot "$boot"
    mkfs.btrfs -L nixos /dev/vg/nixos

    # Create root Btrfs subvolume and mount for installation
    printf "Waiting 5s for /dev/disk/by-label/nixos to appear...\n"
    sleep 5 # wait for by-label to become populated
    mount /dev/disk/by-label/nixos /mnt
    btrfs subvolume create /mnt/root
    umount /mnt
    mount /dev/disk/by-label/nixos -o subvol=root /mnt

    # Mount boot
    mkdir -p /mnt/boot && mount /dev/disk/by-label/boot /mnt/boot

    # Pull latest config, will be preserved on install
    git clone https://github.com/extrange/nixos-config "$nixos_config_dir"
    chown -R 1000 "$nixos_config_dir"

    # Generate hardware config
    printf "Generating hardware-configuration.nix...\n"
    nixos-generate-config --root /mnt
    rm /mnt/etc/nixos/configuration.nix

    # Move hardware config
    mv /mnt/etc/nixos/hardware-configuration.nix "$nixos_config_dir"/hosts/"$hostname"

    clear
    lsblk
    printf "Partitioning complete."
    echo

    # Move ssh keyfile to install's user home dir and set permissions
    SSH_KEYFILE_INSTALL_DIR=/mnt/home/user/.ssh
    mkdir -p "$SSH_KEYFILE_INSTALL_DIR"
    mv "$SSH_KEYFILE_TEMP" "$SSH_KEYFILE_INSTALL_DIR"
    chown -R 1000:100 "$SSH_KEYFILE_INSTALL_DIR"
    chmod 600 "$SSH_KEYFILE_INSTALL_DIR/id_ed25519"

    # Move keyfile to SOPS expected directory
    SOPS_SSH_EXPECTED_DIR=/home/user/.ssh
    mkdir -p "$SOPS_SSH_EXPECTED_DIR"
    ln -s "$SSH_KEYFILE_INSTALL_DIR/id_ed25519" "$SOPS_SSH_EXPECTED_DIR/id_ed25519"

    # +e Don't drop out of root shell on errors
    # +u: Allow unbound variables otherwise tab expansion will fail
    set +euo pipefail

    # Install
    nixos-install --no-root-passwd --flake path:"$nixos_config_dir#$hostname"

}

(
    do_install
)
