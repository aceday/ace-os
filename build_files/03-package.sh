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
    #tlp
    #tlp-rdw
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
    python3.13-devel
    ghex
    # discord
    duf
    ncdu
    android-tools
    fish
    #zsh
    zsh-autocomplete
    zsh-autosuggestions
    hashcat
    util-linux
    # scrcpy

    # Python
    python3-pip
    python3-tkinter

    samba

    # Java
    java-21-openjdk

    distrobox
    podman
    wine
    wine-mono
    # wine-gecko

    # Pen
    wireshark
    aircrack-ng
    hashcat
    reaver
    cowpatty
    hcxtools

    # Multimedia
    shotcut
    darktable
    gimp
    blender
    perl-Image-ExifTool
    ImageMagick

    # QEMU
    qemu-device-display-virtio-gpu
    qemu-device-display-virtio-gpu-gl

    # File System & Storage
    btrfs-assistant # BTRFS GUI tool
    duperemove
    f3 # Flash memory tester
    lzip
    snapper # BTRFS snapshot management   
    picocom

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

    tlpui
    lutris

    gutenprint
    gutenprint-cups
    lprint
)

if [ ${#PKGS_TO_INSTALL[@]} -gt 0 ]; then
    dnf5 install -y "${PKGS_TO_INSTALL[@]}"
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

rpm --import /usr/share/ublue-tr/chrome-workarounds/linux_signing_key.pub
echo "collecting information on where rpm put the key for future reference"
echo "Downloading Google Chrome"
echo "Verified Google Chrome RPM containing $TODAYS_CHROME_VERSION"
# Google Chrome V2
# Ensure we have a clean area
rm -rf /opt/google/ || true

mkdir -p /usr/share/ublue-tr/chrome-workarounds
mkdir -p /tmp/chrome-workarounds
CHROME_DIR=/usr/share/ublue-tr/chrome-workarounds
CHROME_RPM="$CHROME_DIR/google-chrome-stable_current_x86_64.rpm"
CHROME_KEY="$CHROME_DIR/linux_signing_key.pub"

echo "Downloading Google Signing Key"
curl -fSLo "$CHROME_KEY" https://dl.google.com/linux/linux_signing_key.pub

echo "Importing Google signing key into rpm keyring"
# import; if already present this will typically return non-zero — let rpm show useful info
if ! rpm --import "$CHROME_KEY"; then
    echo "Warning: rpm --import returned non-zero. Continuing so we can show rpm -K output for diagnosis."
fi

echo "Collecting information on where rpm put the key for future reference"
ls -l /etc/pki/rpm-gpg | grep -v fedora | grep -v rpmfusion || true
rpm -qa gpg-pubkey* --qf '%{NAME}-%{VERSION}-%{RELEASE} %{PACKAGER}\n' | grep -i 'google' || true

echo "Downloading Google Chrome RPM"
curl -fSLo "$CHROME_RPM" https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm

echo "Verifying Google Chrome RPM signature"
# rpm -K returns 0 on success; capture output for better diagnostics
if ! rpm -K "$CHROME_RPM"; then
    echo "ERROR: RPM verification failed for $CHROME_RPM"
    echo "Showing rpm -Kv output for diagnosis:"
    rpm -Kv "$CHROME_RPM" || true
    echo "If the signature check fails, ensure the Google key imported successfully."
    # Do not attempt to install an unverified package; exit with non-zero to surface failure
    exit 1
fi

# Save so we can verify the version later
TODAYS_CHROME_VERSION=$(rpm -qp --queryformat '%{VERSION}' "$CHROME_RPM") || true
echo "$TODAYS_CHROME_VERSION" > "$CHROME_DIR/google-chrome-current-version"

echo "Verified Google Chrome RPM containing $TODAYS_CHROME_VERSION"
echo "Installing Google Chrome via dnf5"
# Use dnf5 to handle dependencies (requires root)
dnf5 install -y "$CHROME_RPM"
rm -f "$CHROME_RPM"

# VS Code Native
wget --no-check-certificate https://update.code.visualstudio.com/latest/linux-rpm-x64/stable -O code-latest-x64.rpm
sudo dnf5 install -y ./code-latest-x64.rpm
rm ./code-latest-x64.rpm

# Virtualbox based from rpm
wget --no-check-certificate https://download.virtualbox.org/virtualbox/7.1.12/VirtualBox-7.1-7.1.12_169651_fedora40-1.x86_64.rpm
sudo dnf5 install -y ./VirtualBox-7.1-7.1.12_169651_fedora40-1.x86_64.rpm
rm ./VirtualBox-7.1-7.1.12_169651_fedora40-1.x86_64.rpm
/sbin/vboxconfig

# Install winboat(beta)
wget https://release-assets.githubusercontent.com/github-production-release-asset/960420129/5a1a5b9c-a404-4a21-81b3-93bb4cc0bcab?sp=r&sv=2018-11-09&sr=b&spr=https&se=2025-10-24T14%3A27%3A31Z&rscd=attachment%3B+filename%3Dwinboat-0.8.7-x86_64.rpm&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2025-10-24T13%3A27%3A16Z&ske=2025-10-24T14%3A27%3A31Z&sks=b&skv=2018-11-09&sig=Wpc9xLHcBMwjxhWqm%2BZCUUQ4g6QWZMIlucxDQ66XdN0%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2MTMxNDM0OCwibmJmIjoxNzYxMzEyNTQ4LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.VFsrWyWwgQ_NUCCc4NcnKxM_G8GRruA-7uJZlDdxbA4&response-content-disposition=attachment%3B%20filename%3Dwinboat-0.8.7-x86_64.rpm&response-content-type=application%2Foctet-stream
sudo dnf5 install -y ./winboat-0.8.7-x86_64.rpm
rm ./winboat-0.8.7-x86_64.rpm


#git clone https://github.com/ZerBea/hcxdumptool.git
#cd hcxdumptool
#make -j $(nproc)
#make install
#make install PREFIX=/usr/local (as super user)

echo "::endgroup::"

