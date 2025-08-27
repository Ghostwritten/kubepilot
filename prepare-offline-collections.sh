#!/bin/bash
# =============================================================================
# KubePilot Offline Collections Preparation Script
# =============================================================================
# This script prepares Ansible collections for offline deployment
# by downloading and packaging them for air-gapped environments
#
# Usage: ./prepare-offline-collections.sh
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OFFLINE_DIR="${SCRIPT_DIR}/offline"
COLLECTIONS_DIR="${OFFLINE_DIR}/ansible-collections"
PACKAGE_NAME="kubepilot-ansible-collections-$(date +%Y%m%d)"
PACKAGE_FILE="${OFFLINE_DIR}/${PACKAGE_NAME}.tar.gz"

echo "📦 KubePilot Offline Collections Preparation"
echo "============================================"
echo ""

# Function to print status messages
print_status() {
    echo "📌 $1"
}

print_success() {
    echo "✅ $1"
}

print_error() {
    echo "❌ $1"
}

# Check prerequisites
print_status "Checking prerequisites..."

if ! command -v ansible-galaxy &> /dev/null; then
    print_error "ansible-galaxy command not found!"
    exit 1
fi

if [[ ! -f "${SCRIPT_DIR}/requirements.yml" ]]; then
    print_error "requirements.yml not found in ${SCRIPT_DIR}"
    exit 1
fi

print_success "Prerequisites check passed"

# Create offline directory structure
print_status "Creating offline directory structure..."
mkdir -p "$COLLECTIONS_DIR"
mkdir -p "${OFFLINE_DIR}/docs"

# Download collections if not already present
if [[ ! -f "${COLLECTIONS_DIR}/requirements.yml" ]] || [[ $(find "$COLLECTIONS_DIR" -name "*.tar.gz" | wc -l) -lt 5 ]]; then
    print_status "Downloading Ansible collections..."
    
    # Clean and re-download
    rm -f "${COLLECTIONS_DIR}"/*.tar.gz
    rm -f "${COLLECTIONS_DIR}/requirements.yml"
    
    ansible-galaxy collection download -r requirements.yml -p "$COLLECTIONS_DIR" --no-deps
    
    if [[ $? -eq 0 ]]; then
        print_success "Collections downloaded successfully"
    else
        print_error "Failed to download collections"
        exit 1
    fi
else
    print_success "Collections already downloaded"
fi

# Create installation guide
print_status "Creating installation documentation..."

cat > "${OFFLINE_DIR}/README-OFFLINE-INSTALL.md" << 'INSTALL_DOC'
# KubePilot Offline Ansible Collections Installation

## Overview

This package contains all required Ansible collections for KubePilot offline deployment. These collections provide essential modules for system configuration, container management, and Kubernetes deployment in air-gapped environments.

## Package Contents

```
kubepilot-ansible-collections-YYYYMMDD.tar.gz
├── ansible-collections/                    # Collection tar.gz files
│   ├── ansible-posix-2.1.0.tar.gz
│   ├── community-general-11.2.0.tar.gz
│   ├── kubernetes-core-6.1.0.tar.gz
│   ├── community-docker-4.7.0.tar.gz
│   ├── community-crypto-3.0.3.tar.gz
│   └── requirements.yml
├── install-ansible-collections-offline.sh  # Installation script
├── docs/                                   # Documentation
└── README-OFFLINE-INSTALL.md              # This file
```

## Prerequisites

- ansible-core (version 2.15+) must be installed on the target system
- Required system: RHEL 8+, Ubuntu 20.04+, or similar Linux distribution
- Sufficient disk space: ~50MB for all collections

### Install ansible-core (if not present)

**RHEL/CentOS/Rocky Linux:**
```bash
sudo dnf install ansible-core
```

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install ansible-core
```

## Installation Steps

### 1. Extract the package
```bash
tar -xzf kubepilot-ansible-collections-YYYYMMDD.tar.gz
cd kubepilot-ansible-collections-YYYYMMDD/
```

### 2. Run the installation script
```bash
./install-ansible-collections-offline.sh
```

### 3. Verify installation
```bash
ansible-galaxy collection list
```

You should see the following collections installed:
- ansible.posix (2.1.0+)
- community.general (11.0.0+)
- kubernetes.core (6.0.0+)
- community.docker (4.0.0+)
- community.crypto (3.0.0+)

## Manual Installation (Alternative)

If the script fails, you can install collections manually:

```bash
cd ansible-collections/
ansible-galaxy collection install *.tar.gz --force
```

## Verification

Test that essential modules are available:

```bash
# Test system management modules
ansible-doc community.general.pam_limits
ansible-doc ansible.posix.selinux

# Test Kubernetes modules  
ansible-doc kubernetes.core.k8s

# Test container modules
ansible-doc community.docker.docker_container
```

## Troubleshooting

### Permission Issues
If you encounter permission errors, the collections may be installed system-wide:
```bash
sudo ./install-ansible-collections-offline.sh
```

### Collection Conflicts
If you have older versions installed, use `--force` flag:
```bash
ansible-galaxy collection install *.tar.gz --force
```

### Verification Failures
Check if ansible-core is properly installed and accessible:
```bash
ansible --version
ansible-galaxy --version
```

## Integration with KubePilot

After successful installation, you can proceed with KubePilot deployment:

```bash
# Navigate to KubePilot directory
cd /path/to/kubepilot/

# Run SSH trust setup
ansible-playbook -i inventory/k8s01/inventory.ini ssh_trust.yml

# Deploy Kubernetes cluster
ansible-playbook -i inventory/k8s01/inventory.ini cluster.yml
```

## Support

For issues specific to offline collections installation, check:
1. Ansible version compatibility
2. System requirements
3. File permissions
4. Network connectivity (should not be required for offline install)

Collection versions and dependencies are frozen at download time to ensure consistent offline deployment.
INSTALL_DOC

print_success "Installation documentation created"

# Create checksums file
print_status "Generating checksums..."
(
cd "$COLLECTIONS_DIR"
sha256sum *.tar.gz > checksums.sha256
sha256sum requirements.yml >> checksums.sha256
)
print_success "Checksums generated"

# Copy installation script
# Skip copying - file already in place

# Create the final package
print_status "Creating distribution package..."
(
cd "$OFFLINE_DIR"
tar -czf "$PACKAGE_FILE" \
    ansible-collections/ \
    install-ansible-collections-offline.sh \
    README-OFFLINE-INSTALL.md \
    docs/
)

if [[ -f "$PACKAGE_FILE" ]]; then
    PACKAGE_SIZE=$(du -h "$PACKAGE_FILE" | cut -f1)
    print_success "Package created: $PACKAGE_FILE ($PACKAGE_SIZE)"
    
    # Generate final checksums
    (
    cd "$OFFLINE_DIR"
    sha256sum "$(basename "$PACKAGE_FILE")" > "$(basename "$PACKAGE_FILE").sha256"
    )
    
    print_success "Package checksum: $(basename "$PACKAGE_FILE").sha256"
else
    print_error "Failed to create package"
    exit 1
fi

echo ""
print_success "🎉 Offline collections package preparation completed!"
echo ""
echo "📋 Package Details:"
echo "=================="
echo "📦 Package: $PACKAGE_FILE"
echo "📏 Size: $PACKAGE_SIZE"
echo "🔐 Checksum: ${PACKAGE_FILE}.sha256"
echo ""
echo "📤 Distribution Instructions:"
echo "============================="
echo "1. Transfer ${PACKAGE_NAME}.tar.gz to target offline environment"
echo "2. Transfer ${PACKAGE_NAME}.tar.gz.sha256 for integrity verification"
echo "3. On target system: tar -xzf ${PACKAGE_NAME}.tar.gz"
echo "4. Run: ./install-ansible-collections-offline.sh"
echo ""
echo "📚 Documentation: README-OFFLINE-INSTALL.md (included in package)"
