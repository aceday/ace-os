#!/bin/bash
echo "::group:: ===$(basename "$0")==="

set -ouex pipefail
shopt -s nullglob

PKGS_TO_INSTALL=(
    btop
    nvim
    rclone
    go
    7z
    libvirt
    virt-manager
    obs-studio
    tlp
    tlp-rdw
    fuse
    gcr3
    hexedit
    nodejs-npm
    moreutils
    go
    rust
)

# Install packages from fedora repos
if [ ${#PKGS_TO_INSTALL[@]} -gt 0 ]; then
    dnf5 install -y "${PKGS_TO_INSTALL[@]}"
fi

echo "::endgroup::"

