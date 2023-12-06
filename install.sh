#!/usr/bin/env bash

set -euo pipefail

# https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check arguments
if [[ "$#" -ne 1 ]]; then
    printf "Usage: ./install.sh <path-to-install-disk>"
    exit
fi

# Check if we are running as root
if [[ "$EUID" -ne 0 ]]; then
    printf "Please run as root\n"
    exit 1
fi

target=$1

if [[ ! -b "$target" ]]; then
    printf "%s is not a valid block device\n" "$target"
    exit 1
fi

printf "\n${RED}### By continuing, all data in %s will be deleted! ###\n\n${NC}" "$target"

read -rp "To continue, enter YES in caps: " confirm && [[ $confirm == 'YES' ]] || exit 1

# Echo commands and print timestamp
# https://stackoverflow.com/questions/50989501/bash-highlight-command-before-execution-set-x/62620480#62620480
PS4='\033[1;34m$(date +%H:%M:%S):\033[0m '
set -x

# Create partition table
parted "$target" 