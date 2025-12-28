#!/bin/bash

echo "::group:: ===$(basename "$0")==="

set -ouex pipefail

shopt -s nullglob

# AURS
AUR_PKGS=(
  heidisql
)
AUR_PKGS_STR="${AUR_PKGS[*]}"

su - build -c "
set -xeuo pipefail
paru -S --noconfirm --needed $AUR_PKGS_STR
"


echo "::endgroup::"
