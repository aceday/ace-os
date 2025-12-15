#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

cat << 'EOF' > /usr/share/libalpm/hooks/package-cleanup.hook
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = *

[Action]
Description = Cleaning up package cache...
Depends = coreutils
When = PostTransaction
Exec = /usr/bin/rm -rf /var/cache/pacman/pkg
EOF

pacman-key --init
pacman -Syu --noconfirm

pacman-key --recv-keys F3B607488DB35A47 --keyserver keyserver.ubuntu.com
pacman-key --lsign-key F3B607488DB35A47

pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
pacman-key --lsign-key 3056513887B78AEB

pacman -U --noconfirm \
  'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-keyring-20240331-1-any.pkg.tar.zst' \
  'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-mirrorlist-22-1-any.pkg.tar.zst' \
  'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-v3-mirrorlist-22-1-any.pkg.tar.zst' \
  'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
  'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

cat <<EOF > /tmp/cachyos-repos
[cachyos-v3]
Include = /etc/pacman.d/cachyos-v3-mirrorlist

[cachyos-core-v3]
Include = /etc/pacman.d/cachyos-v3-mirrorlist

[cachyos-extra-v3]
Include = /etc/pacman.d/cachyos-v3-mirrorlist

[cachyos]
Include = /etc/pacman.d/cachyos-mirrorlist

EOF

cat <<EOF >> /etc/pacman.conf

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF

cat /etc/pacman.conf
cat /etc/pacman.conf >> /tmp/cachyos-repos
mv /tmp/cachyos-repos /etc/pacman.conf

pacman -Sy --noconfirm pacman
pacman -Sy --noconfirm $(pacman -Qq)

# Base Packages
packages=(
  base
  dracut

  linux-cachyos-bore
  linux-cachyos-bore-headers
  linux-cachyos-bore-nvidia
  linux-firmware

  ostree
  systemd
  btrfs-progs
  e2fsprogs
  xfsprogs
  binutils
  dosfstools
  skopeo
  dbus
  dbus-glib
  glib2
  shadow

  chaotic-aur/bootc

  patchelf
  zip
  nano
  rsync
  coreutils
  binutils
  archlinux-keyring
  bzip2
  file
  filesystem
  findutils
  gawk
  gcc-libs
  gettext
  glibc
  grep
  gzip
  iproute2
  iputils
  licenses
  pacman
  pciutils
  procps-ng
  psmisc
  gcc
  rust
  make
  tmux
  ostree
  systemd
  btrfs-progs


)
pacman -S --noconfirm "${packages[@]}"

# Base Packages - Utilities
packages=(
  sudo
  bash
  bash-completion
  jq
  less
  lsof
  nano
  openssh
  man-db
  wget
  tree
  usbutils
  vim
  glibc-locales
  tar
  udev
  curl
  unzip
  tuned
  tuned-ppd
  python3
  python-pip

  openssh
  dropbear
  perl

)
pacman -Sy --noconfirm "${packages[@]}"

# Packages
packages=(
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
  winetricks
  wireshark
  aircrack-ng
  hashcat
  reaver
  cowpatty
  hcxtools

  shotcut
  darktable
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

pacman -Sy --noconfirm "${packages[@]}"

echo "::endgroup::"
