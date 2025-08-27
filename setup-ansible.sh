#!/bin/bash
# =============================================================================
# KubePilot Ansible Environment Setup Script
# =============================================================================
# This script prepares the Ansible environment for KubePilot deployment
# 
# Usage: ./setup-ansible.sh
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REQUIREMENTS_FILE="${SCRIPT_DIR}/requirements.yml"

echo "🚀 KubePilot Ansible Environment Setup"
echo "====================================="
echo ""

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "⚠️  This script should not be run as root"
   exit 1
fi

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

# Check if ansible is installed
if ! command -v ansible &> /dev/null; then
    print_error "Ansible is not installed!"
    echo ""
    echo "Please install Ansible first:"
    echo "  RHEL/CentOS: sudo dnf install ansible-core"
    echo "  Ubuntu/Debian: sudo apt install ansible-core"
    echo "  Or via pip: pip install ansible"
    exit 1
fi

# Display current Ansible version
ANSIBLE_VERSION=$(ansible --version | head -n1)
print_success "Found: ${ANSIBLE_VERSION}"

# Check if requirements.yml exists
if [[ ! -f "$REQUIREMENTS_FILE" ]]; then
    print_error "requirements.yml not found at $REQUIREMENTS_FILE"
    exit 1
fi

print_success "Found requirements.yml"

# Install collections
print_status "Installing Ansible collections..."
if ansible-galaxy collection install -r "$REQUIREMENTS_FILE"; then
    print_success "All collections installed successfully"
else
    print_error "Failed to install some collections"
    exit 1
fi

# Display installed collections
echo ""
print_status "Currently installed collections:"
ansible-galaxy collection list

# Verify essential modules are available
echo ""
print_status "Verifying essential modules..."

ESSENTIAL_MODULES=(
    "community.general.pam_limits"
    "ansible.posix.selinux" 
    "ansible.posix.firewalld"
    "kubernetes.core.k8s"
    "community.docker.docker_container"
)

ALL_MODULES_FOUND=true

for module in "${ESSENTIAL_MODULES[@]}"; do
    if ansible-doc "$module" &> /dev/null; then
        print_success "✓ $module"
    else
        print_error "✗ $module (not found)"
        ALL_MODULES_FOUND=false
    fi
done

echo ""

if [[ "$ALL_MODULES_FOUND" == true ]]; then
    print_success "All essential modules are available!"
    echo ""
    echo "🎉 Ansible environment is ready for KubePilot!"
    echo ""
    echo "Next steps:"
    echo "  1. Review inventory configuration: inventory/k8s01/"
    echo "  2. Run SSH trust setup: ansible-playbook ssh_trust.yml"  
    echo "  3. Deploy cluster: ansible-playbook cluster.yml"
    echo ""
else
    print_error "Some essential modules are missing!"
    echo ""
    echo "Try running: ansible-galaxy collection install -r requirements.yml --force"
    exit 1
fi
