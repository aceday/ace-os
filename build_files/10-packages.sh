#!/bin/bash

set -oue pipefail

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail
shopt -s nullglob

# VLC
# dnf install vlc-plugins-freeworld -y --exclude=vlc-plugins-base
dnf install -y vlc --setopt=exclude=vlc-plugins-freeworld

    # libreoffice
    # mysql
    # mysql-server
    # mysql-test
    # mysql-common
    # zsh-autocomplete
    # zsh-autosuggestions
    # p7zip
    # p7zip-plugins
    # shotcut
    # samba
    # java-21-openjdk
    # qemu-device-display-virtio-gpu
    # qemu-device-display-virtio-gpu-gl
    # gutenprint
    # gutenprint-cups
    # 
    
    # blender
    # perl-Image-ExifTool
    # ImageMagick
    
    # libvirt
    # virt-manager

PKGS_TO_INSTALL=(

    btop
    nvim
    rclone
    go

    lutris
    wget
    7z
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
    darktable
    aria2
    mycli


    nmap

    rar

    clang
    ccache
    ghex

    duf
    ncdu
    android-tools
    fish

    hashcat
    util-linux

    python3-pip
    python3-tkinter

    php


    distrobox
    podman
    wine
    wine-mono
    winetricks
    wireshark
    aircrack-ng
    hashcat
    reaver
    cowpatty
    hcxtools

    darktable

    duperemove
    f3
    lzip
    snapper    
    picocom

    i2c-tools
    lm_sensors
)




    # # Hardware & Drivers
    # ddcutil
    # input-remapper
    # iwd # iNet Wireless Daemon
    # libcec # HDMI CEC library

    # # Display & Graphics
    # cage # Wayland compositor for single applications
    # extest.i686 # X extension tester
    # vulkan-tools
    # wlr-randr # Wayland output management
    # xrandr

if [ ${#PKGS_TO_INSTALL[@]} -gt 0 ]; then
    dnf5 install -y "${PKGS_TO_INSTALL[@]}"
fi


PKGS_TO_UNINSTALL=(
    nvtop
)

if [ ${#PKGS_TO_UNINSTALL[@]} -gt 0 ]; then
    dnf5 remove -y "${PKGS_TO_UNINSTALL[@]}"
fi

# VS Code Native
wget --no-check-certificate https://update.code.visualstudio.com/latest/linux-rpm-x64/stable -O code-latest-x64.rpm
sudo dnf5 install -y ./code-latest-x64.rpm
rm ./code-latest-x64.rpm

echo "::endgroup::"

