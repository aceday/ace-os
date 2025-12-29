#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Sy --noconfirm

# AURS
AUR_PKGS=(
  heidisql
  heidisql-qt6
  dxvk-bin
  wine-stable
  wine-stable-mono
  winetricks-git
  lutris
)
AUR_PKGS_STR="${AUR_PKGS[*]}"

su - build -c "
set -xeuo pipefail
paru -S --noconfirm --needed $AUR_PKGS_STR
"


echo "::endgroup::"
