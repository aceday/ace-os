#!/bin/bash

set -oue pipefail

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail
shopt -s nullglob


# --- Handle optfix entries (packages that install into /opt) ---
# Read optfix list from a recipe file if provided as $1. Be tolerant when
# invoked without args (we run with set -u) and when helper functions are
# not available in the build environment.
RECIPE_PATH="${1:-}"
OPTFIX=()

if declare -f get_yaml_array >/dev/null 2>&1; then
    # Use existing helper if present (keeps compatibility with the rest of the build)
    get_yaml_array OPTFIX '.optfix[]' "$RECIPE_PATH"
else
    # Fallback: a tiny parser that extracts items under an 'optfix:' YAML list
    if [ -n "$RECIPE_PATH" ] && [ -f "$RECIPE_PATH" ]; then
        mapfile -t OPTFIX < <(
            awk '
                /^optfix:[[:space:]]*$/ { inblock=1; next }
                inblock && /^[[:space:]]*-/ {
                    sub(/^[[:space:]]*-[[:space:]]*/, "");
                    gsub(/^[[:space:]]+|[[:space:]]+$/,"");
                    print
                    next
                }
                inblock && /^[^[:space:]]/ { exit }
            ' "$RECIPE_PATH"
        )
    fi
fi

if [ ${#OPTFIX[@]} -gt 0 ]; then
    echo "Creating symlinks to fix packages that install to /opt"

    # Prepare /var/opt and only create a /opt -> /var/opt symlink if /opt
    # does not already exist (avoid clobbering a real /opt directory).
    mkdir -p "/var/opt"
    if [ ! -e "/opt" ]; then
        ln -s "/var/opt" "/opt"
        echo "Created symlink /opt -> /var/opt"
    elif [ -L "/opt" ]; then
        echo "/opt already a symlink; leaving as-is"
    else
        echo "/opt exists and is not a symlink; skipping global /opt -> /var/opt creation"
    fi

    for OPTPKG in "${OPTFIX[@]}"; do
        # sanitize and normalize the name (strip surrounding quotes/whitespace)
        OPTPKG=$(printf '%s' "$OPTPKG" | sed -e 's/^"//' -e 's/"$//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

        # Basic name validation — allow letters, numbers, dot, underscore, dash
        if ! printf '%s' "$OPTPKG" | grep -Eq '^[A-Za-z0-9._-]+$'; then
            echo "Skipping suspicious package name: '$OPTPKG'" >&2
            continue
        fi

        # Ensure the canonical location exists. Do NOT create a symlink under
        # /var/opt yet — creating /var/opt/<pkg> as a symlink before package
        # install will cause RPM unpack to fail (mkdir on existing symlink).
        mkdir -p "/usr/lib/opt/$OPTPKG"

        # If /var/opt/<pkg> is a symlink, remove it so RPM can create the
        # directory during unpack. If it's a non-directory file, back it up.
        if [ -L "/var/opt/$OPTPKG" ]; then
            echo "/var/opt/$OPTPKG is a symlink; removing to allow package to create directory"
            rm -vf "/var/opt/$OPTPKG"
        elif [ -e "/var/opt/$OPTPKG" ] && [ ! -d "/var/opt/$OPTPKG" ]; then
            backup="/var/opt/${OPTPKG}.backup.$(date +%s)"
            mv -v "/var/opt/$OPTPKG" "$backup"
            echo "Backed up existing /var/opt/$OPTPKG -> $backup"
        fi

        echo "Prepared /usr/lib/opt/$OPTPKG (no symlink placed under /var/opt to avoid RPM unpack conflicts)"
    done
fi



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
# Google Chrome V2
# Ensure we have a clean area
rm -rf /opt/google/ || true

mkdir -p /usr/share/ublue-tr/chrome-workarounds
mkdir -p /tmp/chrome-workarounds
CHROME_DIR=/usr/share/ublue-tr/chrome-workarounds
CHROME_RPM="$CHROME_DIR/google-chrome-stable_current_x86_64.rpm"
CHROME_KEY="$CHROME_DIR/linux_signing_key.pub"

echo "Downloading Google Signing Key"
curl -fSLo "$CHROME_KEY" https://dl.google.com/linux/linux_signing_key.pub || true

# Verify the key file exists and is non-empty; retry with wget if curl failed or produced an empty file
if [ ! -s "$CHROME_KEY" ]; then
    echo "Key file $CHROME_KEY is missing or empty; attempting retry with wget..."
    if command -v wget >/dev/null 2>&1; then
        if ! wget -qO "$CHROME_KEY" https://dl.google.com/linux/linux_signing_key.pub; then
            echo "Failed to download Google signing key with wget."
        fi
    else
        echo "wget not available in PATH to retry download."
    fi
fi

if [ ! -s "$CHROME_KEY" ]; then
    echo "ERROR: Google signing key not found at $CHROME_KEY after retries."
    ls -l "$CHROME_DIR" || true
    echo "Aborting to avoid importing a missing key."
    exit 1
fi

echo "Importing Google signing key into rpm keyring"
# import; if already present this will typically return non-zero — show diagnostic and fail early on true import errors
if ! rpm --import "$CHROME_KEY"; then
    echo "ERROR: rpm --import failed for $CHROME_KEY"
    echo "Showing file information for diagnosis:"
    ls -l "$CHROME_KEY" || true
    echo "File head (first 20 lines):"
    head -n 20 "$CHROME_KEY" || true
    exit 1
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

#git clone https://github.com/ZerBea/hcxdumptool.git
#cd hcxdumptool
#make -j $(nproc)
#make install
#make install PREFIX=/usr/local (as super user)

echo "::endgroup::"

