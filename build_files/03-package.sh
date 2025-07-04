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
    vlc-plugins-freeworld
    mpv
    git
    gh
)

# Install packages from fedora repos, prefer vlc-plugins-freeworld and exclude vlc-plugins-base
if [ ${#PKGS_TO_INSTALL[@]} -gt 0 ]; then
    dnf5 install -y --exclude=vlc-plugins-base "${PKGS_TO_INSTALL[@]}"
fi

# Google Chrome
curl -fLo /tmp/google-chrome.rpm https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
dnf5 install -y /tmp/google-chrome.rpm
rm -f /tmp/google-chrome.rpm


echo "::endgroup::"

