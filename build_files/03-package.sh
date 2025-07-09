#!/bin/bash
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
    tlp
    tlp-rdw
    fuse
    gcr3
    hexedit
    nodejs-npm
    moreutils
    go
    rust
    fastfetch
    mpv
    git
    gh
    ffmpeg
    darktable
    torbrowser-launcher
    libreoffice
    aria2

    mysql-server
    mysql-test
    mysql-common

    nmap

    p7zip
    p7zip-plugins
    rar

    # discord
    duf
    ncdu
    android-tools
    fish
    #zsh
    #zsh-autocomplete
    #zsh-autosuggestions
    hashcat
    util-linux
    # scrcpy
    
    # Java
    java-21-openjdk

    distrobox
    podman
    wine
    wine-mono
    # wine-gecko

    # Pen
    wireshark
    

    # Multimedia
    shotcut
    darktable
    gimp
    blender
    
    # QEMU
    qemu-device-display-virtio-gpu
    qemu-device-display-virtio-gpu-gl

    # File System & Storage
    btrfs-assistant # BTRFS GUI tool
    duperemove
    f3 # Flash memory tester
    lzip
    snapper # BTRFS snapshot management   

    # Hardware & Drivers
    ddcutil # DDC/CI control for monitors
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

    
)

# PKGS_TO_EXCLUDE=(
#     vlc-plugins-freeworld
# )


if [ ${#PKGS_TO_INSTALL[@]} -gt 0 ]; then
    dnf5 install -y "${PKGS_TO_INSTALL[@]}"
    # EXCLUDES=$(IFS=, ; echo "${PKGS_TO_EXCLUDE[*]}")
    # dnf5 install -y --exclude="$EXCLUDES" "${PKGS_TO_INSTALL[@]}"
fi

# VLC
dnf install -y vlc --setopt=exclude=vlc-plugins-freeworld

PKGS_TO_UNINSTALL=(
    nvtop
)

if [ ${#PKGS_TO_UNINSTALL[@]} -gt 0 ]; then
    dnf5 remove -y "${PKGS_TO_UNINSTALL[@]}"
fi

# Google Chrome
# rm -rf /opt/google/
# wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm -O /tmp/chrome.rpm
# rpm-ostree install -y /tmp/chrome.rpm
# rm -f /tmp/chrome.rpm
#wget https://dl.google.com/linux/linux_signing_key.pub
#sudo rpm --import linux_signing_key.pub
#dnf5 update -y
#dnf5 install -y google-chrome-stable
set -oue pipefail
mkdir -p /usr/share/ublue-tr/chrome-workarounds
mkdir -p /tmp/chrome-workarounds
echo "Downloading Google Signing Key"
curl https://dl.google.com/linux/linux_signing_key.pub > /usr/share/ublue-tr/chrome-workarounds/linux_signing_key.pub

rpm --import /usr/share/ublue-tr/chrome-workarounds/linux_signing_key.pub

echo "collecting information on where rpm put the key for future reference"
ls -l /etc/pki/rpm-gpg | grep -v fedora | grep -v rpmfusion 
rpm -qa gpg-pubkey* --qf '%{NAME}-%{VERSION}-%{RELEASE} %{PACKAGER}\n' | grep 'linux-packages-keymaster@google.com'

echo "Downloading Google Chrome"
curl https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm > /usr/share/ublue-tr/chrome-workarounds/google-chrome-stable_current_x86_64.rpm
echo "Verifying Google Chrome"
rpm -K /usr/share/ublue-tr/chrome-workarounds/google-chrome-stable_current_x86_64.rpm
# Save so we can verify the version later
TODAYS_CHROME_VERSION=$(rpm -qp --queryformat '%{VERSION}' /usr/share/ublue-tr/chrome-workarounds/google-chrome-stable_current_x86_64.rpm)
echo $TODAYS_CHROME_VERSION > /usr/share/ublue-tr/chrome-workarounds/google-chrome-current-version

echo "Verified Google Chrome RPM containing $TODAYS_CHROME_VERSION"
# dnf5 install -y google-chrome-stable





# VS Code
#sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
# echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
# dnf check-update
dnf5 install -y code-oss # or code-insiders
# rpm-ostree install code -y

echo "::endgroup::"

