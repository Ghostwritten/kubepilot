# KubePilot

**KubePilot** is a powerful, Ansible-based automation tool designed to streamline the deployment of production-ready Kubernetes clusters. It simplifies the complex process of setting up and configuring all the necessary components, from the underlying infrastructure to the Kubernetes control plane and worker nodes.

## Goals

The primary goal of KubePilot is to provide a reliable, repeatable, and customizable way to deploy Kubernetes clusters in a variety of environments, with a special focus on offline (air-gapped) and on-premise setups. It aims to be a more flexible and user-friendly alternative to existing tools like `kubespray`.

## Value Proposition

- **Automated Deployment:** KubePilot fully automates the installation and configuration of Kubernetes, including the container runtime (containerd), CNI (Calico), and other core components.
- **Offline/Air-Gapped Support:**  Designed from the ground up to work in environments without internet access. KubePilot can use a local HTTP server for all necessary packages and container images.
- **Highly Configurable:**  Leveraging a centralized configuration file, KubePilot allows you to easily customize versions of Kubernetes, Docker, Calico, and other components to fit your specific needs.
- **Phased & Modular:** The deployment is broken down into logical phases (system prep, container runtime, Kubernetes install, etc.), allowing for greater control and easier troubleshooting.
- **Idempotent:** Ansible's idempotent nature ensures that you can run the playbooks multiple times with the same outcome, making cluster updates and maintenance more predictable.

## Intended Audience

KubePilot is designed for:

- **DevOps Engineers and SREs** who need to deploy and manage Kubernetes clusters in a consistent and automated fashion.
- **System Administrators** who are responsible for setting up and maintaining the infrastructure for containerized applications.
- **Organizations** that require Kubernetes to run in on-premise data centers or in environments with strict network security policies that prevent direct internet access.

## Key Features

### 🚀 Offline Deployment
- **Air-gapped Support**: Complete offline installation capability
- **Local Package Repository**: Use local HTTP server for packages and container images
- **No Internet Dependency**: All components can be deployed without external connectivity

### ⚙️ Easy Configuration
- **Centralized Configuration**: Single configuration file for all cluster settings
- **Version Management**: Easy customization of Kubernetes, containerd, and CNI versions
- **Environment Flexibility**: Support for various deployment environments

### 📦 Modular Playbooks
- **Phased Deployment**: Logical breakdown into system prep, runtime, and Kubernetes installation
- **Reusable Components**: Modular Ansible roles for maximum reusability
- **Selective Execution**: Run specific phases or components as needed

### 🔒 Air-gapped Support
- **Complete Isolation**: Deploy in environments without internet access
- **Secure Deployment**: Perfect for high-security environments
- **Offline Updates**: Manage cluster updates without external connectivity

### 🎛️ Cluster Customization Options
- **Multi-node Support**: Deploy single-node or multi-node clusters
- **Custom Networking**: Flexible CNI configuration (Calico by default)
- **Storage Options**: Configure various storage backends
- **Security Policies**: Implement custom security configurations

## Quick Start

### Prerequisites
- Ansible 2.9+
- Python 3.6+
- SSH access to target nodes
- Sudo privileges on target nodes

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/kubepilot.git
cd kubepilot
```

2. Configure your inventory:
```bash
cp inventory/sample/hosts.yml inventory/mycluster/hosts.yml
# Edit inventory/mycluster/hosts.yml with your node information
```

3. Configure cluster settings:
```bash
cp inventory/sample/group_vars/all/all.yml inventory/mycluster/group_vars/all/all.yml
# Edit the configuration file as needed
```

4. Deploy the cluster:
```bash
ansible-playbook -i inventory/mycluster/hosts.yml cluster.yml
```

## Configuration

The main configuration is handled through `inventory/{cluster_name}/group_vars/all/all.yml`. Key settings include:

- Kubernetes version
- Container runtime configuration
- Network plugin settings
- Node roles and specifications
- Offline deployment options

## Project Structure

```
kubepilot/
├── ansible.cfg          # Ansible configuration
├── cluster.yml          # Main deployment playbook
├── reset.yml           # Cluster reset playbook
├── inventory/          # Inventory configurations
├── playbooks/          # Additional playbooks
├── roles/              # Ansible roles
└── demo/               # Demo configurations
```

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- Create an issue for bug reports or feature requests
- Check existing issues before creating new ones
- Provide detailed information when reporting issues

## Roadmap

- [ ] Support for additional CNI plugins
- [ ] Enhanced monitoring integration
- [ ] Multi-cluster management
- [ ] Advanced security hardening options
- [ ] Integration with cloud providers

