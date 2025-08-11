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
    sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash intel_iommu=on iommu=pt kvm.ignore_msrs=1"/' "$grub_cfg"
else
    echo 'GRUB_CMDLINE_LINUX_DEFAULT="quiet splash intel_iommu=on iommu=pt kvm.ignore_msrs=1"' >> "$grub_cfg"
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

# Only configure services and modules if we're not in a container build environment
if [ -d /run/systemd/system ]; then
    # Enable and start libvirtd service (only when systemd is running)
    systemctl enable libvirtd.service
    systemctl enable virtqemud.service
    
    # Add user to libvirt group if user exists
    if id "mac" &>/dev/null; then
        usermod -a -G libvirt mac
        usermod -a -G vboxusers mac
    fi
    
    # Load KVM modules if they exist
    if [ -f /lib/modules/$(uname -r)/kernel/arch/x86/kvm/kvm.ko* ]; then
        modprobe kvm 2>/dev/null || true
        modprobe kvm_intel 2>/dev/null || modprobe kvm_amd 2>/dev/null || true
    fi
    
    # VirtualBox setup
    systemctl enable vboxdrv.service 2>/dev/null || true
    systemctl enable vboxautostart-service.service 2>/dev/null || true
    systemctl enable vboxballoonctrl-service.service 2>/dev/null || true
    systemctl enable vboxweb-service.service 2>/dev/null || true
else
    echo "Container build environment detected - skipping systemd and module operations"
    
    # Build VirtualBox kernel modules during image build
    if command -v akmods &> /dev/null; then
        echo "Building VirtualBox kernel modules..."
        akmods --force 2>/dev/null || true
    fi
fi

# Test kernel print
echo "Kernel version: $(uname -r)"

# Create VirtualBox first-boot setup script
cat > /usr/local/bin/vbox-setup.sh << 'EOF'
#!/bin/bash
# VirtualBox first-boot setup script

# Check if VirtualBox kernel modules are loaded
if ! lsmod | grep -q vboxdrv; then
    echo "VirtualBox kernel driver not loaded, attempting to build and load..."
    
    # Install kernel-devel for current kernel if not present
    CURRENT_KERNEL=$(uname -r)
    if ! rpm -q kernel-devel-${CURRENT_KERNEL} &>/dev/null; then
        echo "Installing kernel-devel for current kernel..."
        dnf install -y kernel-devel-${CURRENT_KERNEL} 2>/dev/null || \
        dnf install -y kernel-devel 2>/dev/null || true
    fi
    
    # Build and install VirtualBox kernel modules
    if command -v akmods &> /dev/null; then
        echo "Building VirtualBox kernel modules..."
        akmods --force
        
        # Start VirtualBox services
        systemctl restart vboxdrv.service 2>/dev/null || true
        
        # Load VirtualBox kernel modules
        modprobe vboxdrv 2>/dev/null || true
        modprobe vboxnetflt 2>/dev/null || true
        modprobe vboxnetadp 2>/dev/null || true
        
        echo "VirtualBox setup completed"
    else
        echo "akmods not available, VirtualBox modules may not work"
    fi
else
    echo "VirtualBox kernel driver already loaded"
fi
EOF

chmod +x /usr/local/bin/vbox-setup.sh

# Create systemd service for VirtualBox first-boot setup
cat > /etc/systemd/system/vbox-setup.service << 'EOF'
[Unit]
Description=VirtualBox first-boot setup
After=multi-user.target
Before=display-manager.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/vbox-setup.sh
RemainAfterExit=yes
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Enable the VirtualBox setup service
systemctl enable vbox-setup.service 2>/dev/null || true
