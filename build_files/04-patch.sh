#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -eoux pipefail
set -eoux pipefail

# Define repositories and the packages to be swapped from them
declare -A PKGS_TO_SWAP=(
    ["copr:copr.fedorainfracloud.org:bazzite-org:bazzite"]="wireplumber"
    ["copr:copr.fedorainfracloud.org:bazzite-org:bazzite-multilib"]="pipewire bluez xorg-x11-server-Xwayland mutter"
    ["terra-extras"]="switcheroo-control gnome-shell"
    ["copr:copr.fedorainfracloud.org:ublue-os:staging"]="fwupd"
)

# Helper: check whether a named repo is usable before calling dnf with --repo
repo_exists() {
    local repo="$1"
    # dnf5 --repo expects a repo id; test by listing available packages
    if dnf5 --repo="$repo" list available >/dev/null 2>&1; then
        return 0
    fi
    return 1
}

# Swap packages from the specified repositories (skip missing repos)
for repo in "${!PKGS_TO_SWAP[@]}"; do
    if ! repo_exists "$repo"; then
        echo "Repo '$repo' not found or not usable; skipping swap for: ${PKGS_TO_SWAP[$repo]}"
        continue
    fi

    # Run distro-sync for the repo; if it fails, print a warning and continue.
    set +e
    dnf5 -y distro-sync --repo="$repo" ${PKGS_TO_SWAP[$repo]}
    rc=$?
    set -e
    if [ $rc -ne 0 ]; then
        echo "Warning: distro-sync for repo '$repo' failed (exit $rc). Continuing."
    fi
done
unset -v PKGS_TO_SWAP repo package

# Lock versions for critical system packages
PKGS_TO_LOCK=(
    # GNOME & Display
    gnome-shell
    mutter
    xorg-x11-server-Xwayland

    # Pipewire
    pipewire
    pipewire-alsa
    pipewire-gstreamer
    pipewire-jack-audio-connection-kit
    pipewire-jack-audio-connection-kit-libs
    pipewire-libs
    pipewire-plugin-libcamera
    pipewire-pulseaudio
    pipewire-utils
    wireplumber
    wireplumber-libs

    # Bluetooth
    bluez
    bluez-cups
    bluez-libs
    bluez-obexd

    # Mesa
    mesa-dri-drivers
    mesa-filesystem
    mesa-libEGL
    mesa-libGL
    mesa-libgbm
    mesa-va-drivers
    mesa-vulkan-drivers

    # Firmware
    fwupd
    fwupd-plugin-flashrom
    fwupd-plugin-modem-manager
    fwupd-plugin-uefi-capsule-data

    # Other
    switcheroo-control
)

if [ ${#PKGS_TO_LOCK[@]} -gt 0 ]; then
    dnf5 versionlock add "${PKGS_TO_LOCK[@]}"
fi

#dnf5 install -y kmod-VirtualBox-6.15.6-200.fc42.x86_64
#dnf5 install -y akmod-VirtualBox kernel-devel-6.15.6-200.fc42.x86_64
#mkdir -p /run/akmods/
#akmods --force
echo "::endgroup::"
