#!/bin/bash

# Enable os-prober in GRUB config
grub_cfg="/etc/default/grub"
if grep -q '^GRUB_DISABLE_OS_PROBER=' "$grub_cfg"; then
    sed -i 's/^GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/' "$grub_cfg"
else
    echo 'GRUB_DISABLE_OS_PROBER=false' >> "$grub_cfg"
fi

# Configure GRUB command line options for better power management
if grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=' "$grub_cfg"; then
    sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash intel_iommu=on iommu=pt kvm.ignore_msrs=1 intel_pstate=disable pcie_aspm=force i915.enable_psr=1 i915.enable_fbc=1"/' "$grub_cfg"
else
    echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet splash intel_iommu=on iommu=pt kvm.ignore_msrs=1 intel_pstate=disable pcie_aspm=force i915.enable_psr=1 i915.enable_fbc=1"' >> "$grub_cfg"
fi


# TLP Service
cp ./config/tlp.conf /etc/tlp.conf
systemctl enable --now tlp.service
systemctl start tlp
tlp start

# Battery saving optimizations
echo "# Battery saving configurations" >> /etc/sysctl.d/99-battery-saving.conf
echo "vm.laptop_mode = 5" >> /etc/sysctl.d/99-battery-saving.conf
echo "vm.dirty_writeback_centisecs = 6000" >> /etc/sysctl.d/99-battery-saving.conf
echo "vm.dirty_expire_centisecs = 6000" >> /etc/sysctl.d/99-battery-saving.conf

# Enable power-profiles-daemon for ThinkPad power management
systemctl enable --now power-profiles-daemon

# Configure Intel GPU power saving
echo 'options i915 enable_psr=1 enable_fbc=1 enable_dc=2 disable_power_well=0' > /etc/modprobe.d/i915.conf

# Force disable Intel P-state driver and ensure ACPI CPUfreq is used
echo 'blacklist intel_pstate' > /etc/modprobe.d/disable-intel-pstate.conf
echo 'install intel_pstate /bin/false' >> /etc/modprobe.d/disable-intel-pstate.conf

# ThinkPad specific power optimizations
echo 'options thinkpad_acpi fan_control=1' > /etc/modprobe.d/thinkpad_acpi.conf

# Disable unused wireless protocols for power saving
systemctl mask bluetooth.service
systemctl mask wpa_supplicant.service

# Configure CPU frequency scaling
echo 'GOVERNOR="powersave"' > /etc/default/cpufrequtils

# Ensure ACPI CPUfreq driver is used and verify Intel P-state is disabled
echo "# Force ACPI CPUfreq driver" > /etc/modprobe.d/cpufreq.conf
echo "options acpi-cpufreq" >> /etc/modprobe.d/cpufreq.conf

# Update initramfs to ensure module blacklisting takes effect
update-initramfs -u || dracut -f || echo "Warning: Could not update initramfs"

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
