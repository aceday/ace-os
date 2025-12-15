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
  extra/neovim
  android-tools
  aria2
  aircrack-ng
  btop
  blender
  cage
  cowpatty
  ddcutil
  darktable
  duperemove
  fastfetch
  ffmpeg
  fuse
  f3
  go
  git
  github-cli
  ghex
  gutenprint
  gutenprint-cups
  hcxtools
  hexedit
  i2c-tools
  imagemagick
  input-remapper
  iwd
  jdk-openjdk
  lzip
  libcec
  libvirt
  lm_sensors
  lutris
  moreutils
  mpv
  mysql
  nmap
  obs-studio
  perl-image-exiftool
  picocom
  podman
  powertop
  p7zip
  qemu-guest-agent
  reaver
  rclone
  snapper
  shotcut
  samba
  python-pip
  powertop
  virt-manager
  vulkan-tools
  winetricks
  wine
  wine-mono
  wireshark-qt
  wlr-randr
)

  # python-tk
  # xrandr

pacman -Sy --noconfirm "${packages[@]}"

echo "::endgroup::"
