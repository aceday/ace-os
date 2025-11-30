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
    udiskie
    webp-pixbuf-loader
    wl-clipboard
    wlsunset
    xdg-desktop-portal-gnome
    xdg-user-dirs
    xwayland-satellite
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

mkdir -p "/usr/share/fonts/Maple Mono"

MAPLE_TMPDIR="$(mktemp -d)"
trap 'rm -rf "${MAPLE_TMPDIR}"' EXIT

LATEST_RELEASE_FONT="$(curl "https://api.github.com/repos/subframe7536/maple-font/releases/latest" | jq '.assets[] | select(.name == "MapleMono-Variable.zip") | .browser_download_url' -rc)"
curl -fSsLo "${MAPLE_TMPDIR}/maple.zip" "${LATEST_RELEASE_FONT}"
unzip "${MAPLE_TMPDIR}/maple.zip" -d "/usr/share/fonts/Maple Mono"

echo "::endgroup::"
