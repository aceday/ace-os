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
    fastfetch
    vlc
    mpv
    git
    gh
)

# Install packages from fedora repos
if [ ${#PKGS_TO_INSTALL[@]} -gt 0 ]; then
    dnf5 install -y "${PKGS_TO_INSTALL[@]}"
fi

# Google Chrome
curl -fLo /tmp/google-chrome.rpm https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
dnf5 install -y /tmp/google-chrome.rpm
rm -f /tmp/google-chrome.rpm


echo "::endgroup::"

