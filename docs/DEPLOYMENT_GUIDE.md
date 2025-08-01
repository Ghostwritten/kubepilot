# KubePilot 部署指南

## 📋 概述

KubePilot 是一个基于 Ansible 的 Kubernetes 集群自动化部署工具，支持离线部署和高度自定义配置。

## 🚀 快速开始

### 1. 环境准备

#### 系统要求
- **操作系统**: CentOS 7+, RHEL 7+, Ubuntu 18.04+
- **内存**: 最少 2GB RAM
- **CPU**: 最少 2 核
- **磁盘**: 最少 20GB 可用空间
- **网络**: 节点间网络连通

#### 软件要求
- **Ansible**: 2.9+
- **Python**: 3.6+
- **SSH**: 免密登录配置

### 2. 项目结构

```
kubepilot/
├── cluster.yml              # 主部署 playbook
├── reset.yml               # 集群重置 playbook
├── ansible.cfg             # Ansible 配置
├── playbooks/              # 分阶段 playbook
│   ├── base.yml           # 系统基础配置
│   ├── install_containerd.yml  # 容器运行时安装
│   ├── install_k8s.yml    # Kubernetes 安装
│   ├── install_calico.yml # CNI 网络插件
│   ├── node.yml           # 工作节点加入
│   └── ssh_trust.yml      # SSH 免密配置
├── roles/                  # Ansible 角色
├── inventory/              # 集群配置
│   └── k8s01/
│       ├── inventory.ini   # 节点清单
│       └── group_vars/     # 变量配置
└── demo/                   # 演示配置
```

### 3. 配置集群

#### 3.1 编辑节点清单

编辑 `inventory/k8s01/inventory.ini`:

```ini
[all]
# 控制平面节点
kube-master01 ansible_host=192.168.22.111 node_role=master
kube-master02 ansible_host=192.168.22.114 node_role=master

# 工作节点
kube-node01 ansible_host=192.168.22.112 node_role=worker
kube-node02 ansible_host=192.168.22.113 node_role=worker

[all:vars]
ansible_user=appuser
ansible_ssh_pass=appuser
ansible_become=true
ansible_become_method=sudo

[kube_control_plane]
kube-master01
kube-master02

[kube_node]
kube-node01
kube-node02
```

#### 3.2 配置集群变量

编辑 `inventory/k8s01/group_vars/all.yml`:

```yaml
# Kubernetes 版本
kube_version: "1.31.10"
kube_version_full: "1.31.10-150500.1.1"

# 离线模式配置
offline_mode: true
http_server: "http://192.168.22.130"

# 网络配置
kube_pod_cidr: "10.244.0.0/16"
kube_service_cidr: "10.96.0.0/12"

# 容器运行时
containerd_version: "2.1.3"
```

### 4. 部署集群

#### 4.1 完整部署

```bash
# 部署完整集群
ansible-playbook -i inventory/k8s01/inventory.ini cluster.yml
```

#### 4.2 分阶段部署

```bash
# 阶段 1: SSH 免密配置
ansible-playbook -i inventory/k8s01/inventory.ini cluster.yml --tags ssh

# 阶段 2: 系统基础配置
ansible-playbook -i inventory/k8s01/inventory.ini cluster.yml --tags base

# 阶段 3: 容器运行时安装
ansible-playbook -i inventory/k8s01/inventory.ini cluster.yml --tags containerd

# 阶段 4: Kubernetes 安装
ansible-playbook -i inventory/k8s01/inventory.ini cluster.yml --tags install_k8s

# 阶段 5: CNI 网络插件
ansible-playbook -i inventory/k8s01/inventory.ini cluster.yml --tags install_calico

# 阶段 6: 工作节点加入
ansible-playbook -i inventory/k8s01/inventory.ini cluster.yml --tags join_node
```

### 5. 验证部署

#### 5.1 检查集群状态

```bash
# 在控制平面节点上执行
kubectl get nodes
kubectl get pods --all-namespaces
kubectl get services --all-namespaces
```

#### 5.2 检查网络连通性

```bash
# 测试 Pod 网络
kubectl run test-pod --image=busybox --rm -it --restart=Never -- nslookup kubernetes.default

# 测试服务网络
kubectl run test-service --image=nginx --port=80
kubectl expose pod test-service --type=NodePort
```

### 6. 集群管理

#### 6.1 添加工作节点

1. 在 `inventory.ini` 中添加新节点
2. 运行工作节点加入阶段：

```bash
ansible-playbook -i inventory/k8s01/inventory.ini cluster.yml --tags join_node
```

#### 6.2 集群重置

```bash
# 完全重置集群
ansible-playbook -i inventory/k8s01/inventory.ini reset.yml
```

#### 6.3 集群升级

1. 更新配置文件中的版本号
2. 运行升级 playbook：

```bash
ansible-playbook -i inventory/k8s01/inventory.ini cluster.yml --tags upgrade
```

## 🔧 故障排除

### 常见问题

#### 1. SSH 连接失败
- 检查 SSH 密钥配置
- 确认防火墙设置
- 验证网络连通性

#### 2. 容器运行时问题
- 检查 containerd 服务状态
- 验证镜像仓库配置
- 查看容器运行时日志

#### 3. Kubernetes 组件问题
- 检查 kubelet 服务状态
- 验证 API server 连通性
- 查看组件日志

#### 4. 网络插件问题
- 检查 Calico 组件状态
- 验证网络策略配置
- 查看网络组件日志

### 日志查看

```bash
# 查看 kubelet 日志
journalctl -u kubelet -f

# 查看 containerd 日志
journalctl -u containerd -f

# 查看 Kubernetes 组件日志
kubectl logs -n kube-system <pod-name>
```

## 📚 高级配置

### 自定义网络配置

```yaml
# 自定义 Pod CIDR
kube_pod_cidr: "10.244.0.0/16"

# 自定义 Service CIDR
kube_service_cidr: "10.96.0.0/12"

# 自定义 DNS 配置
dns_domain: "cluster.local"
dns_servers:
  - "8.8.8.8"
  - "114.114.114.114"
```

### 资源限制配置

```yaml
# Kubelet 资源配置
kubelet_max_pods: 110
kubelet_system_reserved_cpu: "100m"
kubelet_system_reserved_memory: "100Mi"
kubelet_kube_reserved_cpu: "100m"
kubelet_kube_reserved_memory: "100Mi"
```

### 安全配置

```yaml
# RBAC 配置
rbac_enabled: true

# 网络策略
network_policy_enabled: true

# Pod 安全策略
pod_security_policy_enabled: true
```

## 🆘 支持

如果遇到问题，请：

1. 查看日志文件
2. 检查配置文件
3. 验证网络连通性
4. 提交 Issue 到项目仓库

## 📄 许可证

本项目采用 MIT 许可证。 