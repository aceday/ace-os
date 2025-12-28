#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

  # linux-cachyos-bore-nvidia-open
  # nvidia-utils
  # nvidia-settings
  # opencl-nvidia

# Base Packages
packages=(
  base
  binutils
  bootc
  btrfs-progs
  dbus
  dbus-glib
  dosfstools
  dracut
  e2fsprogs
  glib2
  linux-cachyos-bore
  linux-cachyos-bore-headers
  linux-firmware
  mkinitcpio
  ostree
  polkit
  power-profiles-daemon
  shadow
  skopeo
  systemd
  xfsprogs
)
pacman -S --noconfirm "${packages[@]}"

# Drivers
packages=(
  intel-media-driver
  intel-ucode
  libglvnd
  libva-intel-driver
  mesa
  mesa-utils
  vulkan-icd-loader
  vulkan-intel
  vulkan-tools
)
pacman -S --noconfirm "${packages[@]}"

# Network Drivers
packages=(
  bluez
  bluez-utils
  firewalld
  iw
  libmtp
  nss-mdns
  networkmanager
  rfkill
  samba
  smbclient
  udiskie
  udisks2
  wpa_supplicant
  wireless_tools
)
pacman -S --noconfirm "${packages[@]}"

# Audio Drivers
packages=(
  alsa-firmware
  linux-firmware-intel
  pipewire
  pipewire-audio
  pipewire-ffado
  pipewire-libcamera
  pipewire-pulse
  pipewire-zeroconf
  sof-firmware
  wireplumber
)
pacman -S --noconfirm "${packages[@]}"

# Media/Install utilities/Media drivers
packages=(
  acpid
  dmidecode
  librsvg
  libglvnd
  mesa-utils
  ntfs-3g
  playerctl
  plymouth
  qt6-multimedia
  qt6-multimedia-ffmpeg
  vulkan-tools
  wayland-utils
)
pacman -S --noconfirm "${packages[@]}"

# CLI Utilities
packages=(
  bash
  bash-completion
  curl
  git
  glibc-locales
  jq
  less
  lsof
  man-db
  nano
  openssh
  sudo
  tar
  tree
  udev
  usbutils
  vim
  wget
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

  # cachyos-extra-v3/ananicy-cpp
  # cachyos-extra-v3/libmirage
  # cachyos-extra-v3/scx-tools
  # cachyos/scx-scheds
  # cachyos/scxctl

# Additional packages
packages=(
  adw-gtk-theme
  base-devel
  btop
  ccache
  clang
  cmake
  dnsmasq
  duf
  distrobox
  extra/gvfs-gphoto2
  extra/gvfs-mtp
  extra/mtpfs
  extra/wireguard-tools
  fakeroot
  fastfetch
  ffmpeg
  fish
  fzf
  git
  hexedit
  jq
  mpv
  ncdu
  networkmanager-strongswan
  openvpn
  pavucontrol
  patch
  patchelf
  qemu-audio-alsa
  qemu-full
  qemu-system-x86
  qemu-system-x86-firmware
  rclone
  strongswan
  tlp
  tlp-rdw
  toolbox
  vulkan-tools
  virt-manager
  vi
  xorg-xrandr
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

# Printers
packages=(
  cachyos-extra-v3/print-manager
  cachyos-extra-v3/smbclient
  chaotic-aur/epson-inkjet-printer-202101w
  chaotic-aur/epson-inkjet-printer-filter
  cups
  cups-pdf
  gutenprint
  system-config-printer
)
pacman -S --noconfirm "${packages[@]}"

echo "::endgroup::"
