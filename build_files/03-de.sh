#!/usr/bin/bash

echo "::group:: ===$(basename \"$0\")==="

set -euo pipefail
set -x

dnf install @kde-desktop-environment -y
systemctl enable --force sddm.service

echo "::endgroup::"
