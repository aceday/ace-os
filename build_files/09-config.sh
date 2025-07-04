#!/bin/bash

# Enable os-prober in GRUB config
grub_cfg="/etc/default/grub"
if grep -q '^GRUB_DISABLE_OS_PROBER=' "$grub_cfg"; then
    sed -i 's/^GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/' "$grub_cfg"
else
    echo 'GRUB_DISABLE_OS_PROBER=false' >> "$grub_cfg"
fi


# TLP Service
cp ./config/tlp.conf /etc/tlp.conf
systemctl enable --now tlp.service
tlp start

