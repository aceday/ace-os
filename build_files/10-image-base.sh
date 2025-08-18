#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

# Set default OS name if not provided via ARG
OS_NAME=${OS_NAME:-ace-os}
DEFAULT_TAG=${DEFAULT_TAG:-latest}

RELEASE="$(rpm -E %fedora)"
DATE=$(date +%Y%m%d)

sed -i "s/^VERSION=.*/VERSION=\"${RELEASE} (${OS_NAME^})\"/" /usr/lib/os-release
sed -i "s/^ID=fedora/ID=${OS_NAME}/" /usr/lib/os-release
sed -i "s/^PRETTY_NAME=.*/PRETTY_NAME=\"${OS_NAME^} ${RELEASE}.${DATE} (Fedora)\"/" /usr/lib/os-release
echo "OSTREE_VERSION=\"${DEFAULT_TAG}.${DATE}\"" >> /usr/lib/os-release

sed -i "s/^EFIDIR=.*/EFIDIR=\"fedora\"/" /usr/sbin/grub2-switch-to-blscfg
echo "::endgroup::"