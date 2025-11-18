#!/bin/bash

set -oue pipefail

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail
shopt -s nullglob


# PKGS_TO_UNINSTALL=(
#     vlc-plugins-freeworld
# )

# if [ ${#PKGS_TO_UNINSTALL[@]} -gt 0 ]; then
#     dnf5 remove -y "${PKGS_TO_UNINSTALL[@]}"
# fi

PKGS_TO_INSTALL=(
    btop
    nvim
    rclone
    go
    7z
    libvirt
    virt-manager
    obs-studio
    pulseaudio-libs-devel
    powertop
    fuse
    gcr3
    hexedit
    nodejs-npm
    moreutils
    go
    rust
    fastfetch
    patchelf
    mpv
    git
    gh
    ffmpeg
    darktable
    torbrowser-launcher
    libreoffice
    aria2
    mycli

    mysql
    mysql-server
    mysql-test
    mysql-common

    nmap

    p7zip
    p7zip-plugins
    rar

    clang
    ccache
    ghex

    duf
    ncdu
    android-tools
    fish

    zsh-autocomplete
    zsh-autosuggestions
    hashcat
    util-linux

    python3-pip
    python3-tkinter

    samba
    php

    java-21-openjdk

    distrobox
    podman
    wine
    wine-mono

    wireshark
    aircrack-ng
    hashcat
    reaver
    cowpatty
    hcxtools

    shotcut
    darktable
    gimp
    blender
    perl-Image-ExifTool
    ImageMagick

    qemu-device-display-virtio-gpu
    qemu-device-display-virtio-gpu-gl

    duperemove
    f3
    lzip
    snapper    
    picocom

    # Hardware & Drivers
    ddcutil
    i2c-tools
    input-remapper
    iwd # iNet Wireless Daemon
    libcec # HDMI CEC library
    lm_sensors

    # Display & Graphics
    cage # Wayland compositor for single applications
    extest.i686 # X extension tester
    vulkan-tools
    wlr-randr # Wayland output management
    xrandr

    lutris

    gutenprint
    gutenprint-cups
)
if [ ${#PKGS_TO_INSTALL[@]} -gt 0 ]; then
    dnf5 install -y "${PKGS_TO_INSTALL[@]}"
fi

sh build_files/99-cleanup.sh

# VLC
dnf install -y vlc --setopt=exclude=vlc-plugins-freeworld

sh build_files/99-cleanup.sh


PKGS_TO_UNINSTALL=(
    nvtop
)


if [ ${#PKGS_TO_UNINSTALL[@]} -gt 0 ]; then
    dnf5 remove -y "${PKGS_TO_UNINSTALL[@]}"
fi

sh build_files/99-cleanup.sh

# VS Code Native
wget --no-check-certificate https://update.code.visualstudio.com/latest/linux-rpm-x64/stable -O code-latest-x64.rpm
sudo dnf5 install -y ./code-latest-x64.rpm
rm ./code-latest-x64.rpm

sh build_files/99-cleanup.sh


echo "::endgroup::"

