# KubePilot - Kubernetes Cluster Deployment Tool

A comprehensive Ansible-based tool for deploying production-ready Kubernetes clusters following industry best practices.

## 🎯 **Philosophy & Design Principles**

KubePilot follows industry best practices by **separating deployment from operations**:

- **Deployment Phase**: Focuses solely on creating a secure, production-ready Kubernetes cluster
- **Operations Phase**: Provides guidance and tools for post-deployment configuration and management
- **Security First**: Implements least-privilege principles and security best practices
- **Industry Standards**: Follows Kubernetes and DevOps community standards

## 🚀 **Quick Start**

### 1. Deploy Cluster
```bash
# Deploy a complete Kubernetes cluster
ansible-playbook -i inventory/k8s01/inventory.ini cluster.yml
```

### 2. Configure Remote Access (Optional)
```bash
# Configure kubectl access following security best practices
ansible-playbook -i inventory/k8s01/inventory.ini playbooks/configure_remote_access.yml
```

## 📋 **Deployment Workflow**

### Phase 1: Cluster Deployment
The main deployment focuses on creating a secure, production-ready cluster:

1. **System Preparation**: OS hardening, container runtime setup
2. **Kubernetes Installation**: Control plane and worker node provisioning
3. **Network Configuration**: Calico CNI deployment
4. **Security Setup**: Proper permissions and configurations
5. **Deployment Summary**: Provides comprehensive post-deployment guidance

### Phase 2: Operations Configuration (Optional)
Separate playbook for operational tasks:

1. **Remote Access Setup**: Secure kubectl configuration
2. **Environment Configuration**: Aliases, completion, and tools
3. **Security Recommendations**: RBAC, monitoring, and compliance guidance

## 🔒 **Security Best Practices**

### Deployment Security
- **Least Privilege**: Minimal required permissions for deployment
- **Secure Defaults**: Hardened configurations out of the box
- **Network Isolation**: Proper firewall and network policies
- **Certificate Management**: Secure TLS certificate handling

### Operations Security
- **RBAC Implementation**: Role-based access control
- **User Management**: Specific user accounts with appropriate permissions
- **Audit Logging**: Comprehensive audit trail
- **Network Policies**: Micro-segmentation and security policies

## 📁 **Project Structure**

```
kubepilot/
├── inventory/                 # Cluster inventory definitions
├── playbooks/                # Main deployment playbooks
│   ├── cluster.yml           # Main cluster deployment
│   ├── reset.yml             # Cluster cleanup
│   └── configure_remote_access.yml  # Optional operations setup
├── roles/                    # Ansible roles
│   ├── base/                 # System preparation
│   ├── container_engine/     # Container runtime setup
│   ├── kubernetes/           # Kubernetes installation
│   ├── network_plugin/       # CNI configuration
│   ├── node/                 # Worker node setup
│   └── reset/                # Cleanup operations
└── docs/                     # Documentation
```

## 🎯 **Industry Compliance**

### Separation of Concerns
- **Deployment Tool**: Focuses on infrastructure provisioning
- **Operations Tool**: Handles post-deployment configuration
- **Security Tool**: Implements security best practices

### Best Practices Alignment
- **GitOps Ready**: Supports GitOps workflows
- **CI/CD Compatible**: Integrates with modern CI/CD pipelines
- **Multi-Environment**: Supports development, staging, and production
- **Compliance Ready**: Implements security and compliance standards

## 📚 **Documentation**

### Available Documentation
- [Deployment Guide](docs/DEPLOYMENT_GUIDE.md) - Complete deployment instructions
- [Contributing Guide](docs/CONTRIBUTING.md) - How to contribute to the project
- [Offline Installation](docs/README-OFFLINE-ANSIBLE.md) - Offline deployment guide
- [Cleanup Report](docs/CLEANUP_REPORT.md) - Project cleanup documentation

## 🔧 **Configuration**

### Inventory Configuration
```ini
[kube_control_plane]
kube-master01 ansible_host=192.168.22.111
kube-master02 ansible_host=192.168.22.112
kube-master03 ansible_host=192.168.22.113

[kube_node]
kube-node01 ansible_host=192.168.22.114

[bastion]
bastion01 ansible_host=192.168.22.100
```

### Variables Configuration
```yaml
# Group variables
kube_version: "1.31.9"
cluster_name: "production-cluster"
kube_network:
  pod_subnet: "10.244.0.0/16"
  service_subnet: "10.96.0.0/12"
```

## 🚀 **Advanced Usage**

### Custom Deployments
```bash
# Deploy with custom variables
ansible-playbook -i inventory/k8s01/inventory.ini cluster.yml \
  -e "kube_version=1.31.9" \
  -e "cluster_name=my-cluster"

# Deploy specific components
ansible-playbook -i inventory/k8s01/inventory.ini cluster.yml \
  --tags "kubernetes,network"
```

### Operations Management
```bash
# Configure remote access with custom options
ansible-playbook -i inventory/k8s01/inventory.ini playbooks/configure_remote_access.yml \
  -e "install_kubectl=true" \
  -e "create_aliases=true"

# Reset cluster
ansible-playbook -i inventory/k8s01/inventory.ini reset.yml
```

## 🤝 **Contributing**

We welcome contributions! Please see our [Contributing Guide](docs/CONTRIBUTING.md) for details.

### Development Setup
```bash
# Clone repository
git clone https://github.com/your-org/kubepilot.git
cd kubepilot

# Set up development environment
pip install -r requirements.txt
ansible-galaxy install -r requirements.yml
```

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 **Acknowledgments**

- Kubernetes community for best practices and documentation
- Ansible community for automation patterns and examples
- Security community for security best practices and recommendations

---

**KubePilot**: Deploying Kubernetes clusters with industry best practices and security-first approach.

