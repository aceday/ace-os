#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

add_wants_niri() {
  sed -i "s/\[Unit\]/\[Unit\]\nWants=$1/" "/usr/lib/systemd/user/niri.service"
}

system_services=(
    bootc-fetch-apply-updates
    auditd
    firewalld
    greetd
    podman.socket
)

user_services=(
    dms
    cliphist
    dsearch
    gnome-keyring-daemon.socket
    gnome-keyring-daemon.service
    xwayland-satellite
)

set_preset=(
)

mask_services=(
    systemd-remount-fs.service
    flatpak-add-fedora-repos.service
    rpm-ostree-countme.service
    rpm-ostree-countme.timer
    logrotate.service
    logrotate.timer
    akmods-keygen@akmods-keygen.service
    user@"$( id -u greeter )".service
)

systemctl enable "${system_services[@]}"
systemctl mask "${mask_services[@]}"
systemctl --global enable "${user_services[@]}"
# systemctl --global preset "${set_preset[@]}"

add_wants_niri cliphist.service
add_wants_niri swayidle.service
add_wants_niri xwayland-satellite.service
cat /usr/lib/systemd/user/niri.service

echo "::endgroup::"
