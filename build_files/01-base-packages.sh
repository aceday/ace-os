#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

  # linux-cachyos-bore-nvidia-open

# Base Packages
packages=(
  base
  dracut
  linux-cachyos-server
  linux-cachyos-server-headers
  linux-firmware
  mkinitcpio
  ostree
  bootc
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
  polkit
  power-profiles-daemon
)
pacman -S --noconfirm "${packages[@]}"

# Drivers
packages=(
  intel-ucode
  mesa
  vulkan-intel
  intel-media-driver
  libva-intel-driver

  nvidia-utils
  nvidia-settings
  opencl-nvidia

  vulkan-icd-loader
  vulkan-tools

  libglvnd
  mesa-utils
)
pacman -S --noconfirm "${packages[@]}"

# Network Drivers
packages=(
  libmtp
  nss-mdns
  samba
  smbclient
  networkmanager
  firewalld
  udiskie
  udisks2
  bluez
  bluez-utils
  iw
  wpa_supplicant
  wireless_tools
  rfkill
)
pacman -S --noconfirm "${packages[@]}"

# Audio Drivers
packages=(
  pipewire
  pipewire-pulse
  pipewire-zeroconf
  pipewire-ffado
  pipewire-libcamera
  sof-firmware
  wireplumber
  alsa-firmware
  pipewire-audio
  linux-firmware-intel
)
pacman -S --noconfirm "${packages[@]}"

# Media/Install utilities/Media drivers
packages=(
  librsvg
  libglvnd
  qt6-multimedia
  qt6-multimedia-ffmpeg
  plymouth
  acpid
  dmidecode
  mesa-utils
  ntfs-3g
  vulkan-tools
  wayland-utils
  playerctl
)
pacman -S --noconfirm "${packages[@]}"

# CLI Utilities
packages=(
  sudo
  bash
  bash-completion
  git
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
)
pacman -S --noconfirm "${packages[@]}"

packages=(
  cachyos-settings
  flatpak-git
)
pacman -S --noconfirm "${packages[@]}"

# For AUR packages to be remove later
pacman -Sy --noconfirm --needed base-devel paru rust

# Additional packages
packages=(
  rclone
  toolbox
  clang
  ccache
  cmake
  btop
  fzf
  tlp
  tlp-rdw
  virt-manager
  fastfetch
  fish
  git
  strongswan
  openvpn
  vi
  nano
  mpv
  distrobox
  lutris
  ffmpeg
  hexedit
  ncdu
  duf
  fakeroot
  jq
  dnsmasq
  base-devel
  patch
  patchelf
  networkmanager-strongswan
  extra/wireguard-tools
  adw-gtk-theme
  qemu-audio-alsa
  qemu-system-x86
  qemu-system-x86-firmware
  qemu-full
  vulkan-tools
  pavucontrol
  extra/gvfs-mtp
  extra/gvfs-gphoto2
  extra/mtpfs
)

pacman -S --noconfirm "${packages[@]}"

# Font
packages=(
  wqy-microhei
)

pacman -S --noconfirm "${packages[@]}"


# Tailscale
packages=(
  tailscale
)
pacman -S --noconfirm "${packages[@]}"
# sysctl net.ipv4.conf.default.rp_filter = 1
# sysctl net.ipv4.conf.all.rp_filter = 1

# Install dxvk
# git clone https://aur.archlinux.org/dxvk-bin.git
# cd dxvk-bin
# bash setup_dxvk.sh install
# cd ..
# rm -rf ./dxvk-bin

echo "::endgroup::"
