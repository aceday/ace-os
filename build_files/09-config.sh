#!/bin/bash

# Enable os-prober in GRUB config
grub_cfg="/etc/default/grub"
if grep -q '^GRUB_DISABLE_OS_PROBER=' "$grub_cfg"; then
    sed -i 's/^GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/' "$grub_cfg"
else
    echo 'GRUB_DISABLE_OS_PROBER=false' >> "$grub_cfg"
fi

# Configure GRUB command line options
if grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=' "$grub_cfg"; then
    sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash intel_iommu=on iommu=pt kvm.ignore_msrs=1 intel_pstate=disable"/' "$grub_cfg"
else
    echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet splash intel_iommu=on iommu=pt kvm.ignore_msrs=1 intel_pstate=disable"' >> "$grub_cfg"
fi


# TLP Service
cp ./config/tlp.conf /etc/tlp.conf
systemctl enable --now tlp.service
systemctl start tlp
tlp start

# ZSH mode
# chsh -s /bin/zsh


# VM - KVM/QEMU setup for Fedora Silverblue
sed -i 's/^#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/' /etc/libvirt/libvirtd.conf
sed -i 's/^#unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0770"/' /etc/libvirt/libvirtd.conf
sed -i 's/^#user = "qemu"/user = "mac"/' /etc/libvirt/qemu.conf

# Enable and start libvirtd service
systemctl enable --now libvirtd.service
systemctl enable --now virtqemud.service

# Add user to libvirt group (will take effect after reboot)
usermod -a -G libvirt mac

# Load KVM modules
modprobe kvm
modprobe kvm_intel  # Use kvm_amd for AMD processors

# Test kernel print
echo "Kernel version: $(uname -r)"
