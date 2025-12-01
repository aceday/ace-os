#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -euxo pipefail

# Create directory
mkdir -p /var/roothome

# Install dnf5 plugins
dnf5 -y install dnf5-plugins
echo -n "max_parallel_downloads=16" >>/etc/dnf/dnf.conf

# Enable COPR repositories
    # bazzite-org/bazzite           # Deprecated na
    # sunwire/tlpui                 # powertop muna ako


COPRS=(
    # Bazzite
    bazzite-org/bazzite-multilib
    bazzite-org/LatencyFleX
    bazzite-org/obs-vkcapture
    bazzite-org/rom-properties
    bazzite-org/webapp-manager
    
    # Ublue
    ublue-os/packages
    ublue-os/staging

    # Fonts
    che/nerd-fonts

    # Gaming
    hikariknight/looking-glass-kvmfr
    lizardbyte/beta
    mavit/discover-overlay
    rok/cdemu

    # Hardware
    hhd-dev/hhd

    # Multimedia
    ycollet/audinux

    # Dank linux
    avengemedia/dms
    avengemedia/dms-git
)

for COPR in "${COPRS[@]}"; do
    echo "Enabling copr: $COPR"
    dnf5 -y copr enable "$COPR"
    dnf5 -y config-manager setopt "copr:copr.fedorainfracloud.org:${COPR////:}.priority=98"
done
unset COPR

# Add Terra repo (custom repopath)
dnf5 -y install --nogpgcheck \
    --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' \
    terra-release terra-release-extras

# Add Tailscale repo
dnf5 -y config-manager addrepo --overwrite \
    --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo

# Install RPMFusion repos
dnf5 -y install \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"


# set priorities and exclusions
dnf5 -y config-manager setopt "*bazzite*".priority=1
dnf5 -y config-manager setopt "*akmods*".priority=2


dnf5 -y config-manager setopt "*".exclude="*.aarch64"
dnf5 -y config-manager setopt "*rpmfusion*".priority=5 "*rpmfusion*".exclude="mesa-*"
dnf5 -y config-manager setopt "*fedora*".exclude="mesa-* kernel-core-* kernel-modules-* kernel-uki-virt-*"
dnf5 -y config-manager setopt "*staging*".exclude="scx-scheds kf6-* mesa* mutter* rpm-ostree* systemd* gnome-shell gnome-settings-daemon gnome-control-center gnome-software libadwaita tuned*"

# TLP UI
sudo dnf copr enable sunwire/tlpui
echo "::endgroup::"
