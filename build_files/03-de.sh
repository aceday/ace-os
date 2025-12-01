#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

packages=(
    libwayland-server

    quickshell-git
    dms
    dms-cli
    dms-greeter
    dgop
    glycin-thumbnailer
    gnome-keyring
    gnome-keyring-pam
    greetd
    greetd-selinux
    orca
    swayidle
    webp-pixbuf-loader
    wl-clipboard
    wlsunset
    xdg-desktop-portal-gnome
    xdg-user-dirs
    xwayland-satellite

    morewaita-icon-theme

    i2c-tools
    cliphist
    matugen
    cava
)
dnf5 -y install "${packages[@]}"

# Install install_weak_deps=false
packages=(
    niri
    adw-gtk3-theme
)

dnf5 -y install "${packages[@]}" --setopt=install_weak_deps=False

# Uninstall
packages=(
)
# dnf5 -y remove "${packages[@]}"

echo "::endgroup::"
