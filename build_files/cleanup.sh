#!/usr/bin/bash

set -eoux pipefail

dnf5 clean all
rm -rf /tmp/* || true
rm -rf /var/cache/dnf/* || true
rm -rf /var/tmp/* || true

ostree container commit
