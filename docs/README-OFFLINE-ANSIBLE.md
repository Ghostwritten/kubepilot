# KubePilot Offline Ansible Collections Installation

## 概述

KubePilot作为面向离线环境的Kubernetes集群部署工具，提供了完整的Ansible collections离线安装解决方案。本文档详细说明如何在完全离线（air-gapped）环境中准备和安装所需的Ansible collections。

## 架构说明

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   在线环境      │    │   传输介质      │    │   离线环境      │
│  (准备阶段)     │    │  (USB/光盘)     │    │  (部署阶段)     │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ • 下载collections│    │ • tar.gz包      │    │ • ansible-core  │
│ • 创建安装包    │────▶│ • 安装脚本      │────▶│ • 安装collections│
│ • 生成校验和    │    │ • 文档说明      │    │ • 验证功能      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 准备阶段（在线环境）

### 1. 环境要求
- 安装了ansible-core的Linux系统
- 能够访问Ansible Galaxy (https://galaxy.ansible.com)
- 足够的磁盘空间（约100MB）

### 2. 自动准备（推荐）
```bash
# 在KubePilot项目根目录执行
./prepare-offline-collections.sh
```

这个脚本会：
- 📦 下载所有必需的collections到本地
- 🗜️  打包成单一的tar.gz文件
- 🔐 生成校验和文件
- 📚 创建安装文档

### 3. 手动准备（高级用户）
```bash
# 创建目录
mkdir -p offline/ansible-collections

# 下载collections
ansible-galaxy collection download -r requirements.yml \
    -p offline/ansible-collections --no-deps

# 手动打包
tar -czf kubepilot-ansible-collections-$(date +%Y%m%d).tar.gz \
    offline/
```

### 4. 验证准备结果
```bash
ls -la offline/
# 应该看到：
# kubepilot-ansible-collections-YYYYMMDD.tar.gz      (主包)
# kubepilot-ansible-collections-YYYYMMDD.tar.gz.sha256  (校验和)
```

## 传输阶段

将以下文件传输到离线环境：
1. `kubepilot-ansible-collections-YYYYMMDD.tar.gz` - 主安装包
2. `kubepilot-ansible-collections-YYYYMMDD.tar.gz.sha256` - 校验和文件

传输方式：
- 🔌 USB存储设备
- 💿 CD/DVD
- 🌐 内部文件服务器
- ☁️  内部对象存储

## 部署阶段（离线环境）

### 1. 环境准备
确保离线环境已安装ansible-core：

**RHEL/CentOS/Rocky Linux:**
```bash
sudo dnf install ansible-core
```

**Ubuntu/Debian:**
```bash
sudo apt install ansible-core
```

### 2. 校验文件完整性
```bash
sha256sum -c kubepilot-ansible-collections-YYYYMMDD.tar.gz.sha256
# 输出应该显示: OK
```

### 3. 解压和安装
```bash
# 解压
tar -xzf kubepilot-ansible-collections-YYYYMMDD.tar.gz
cd kubepilot-ansible-collections-YYYYMMDD/

# 运行安装脚本
./install-ansible-collections-offline.sh
```

### 4. 验证安装
```bash
# 检查已安装的collections
ansible-galaxy collection list

# 测试关键模块
ansible-doc community.general.pam_limits
ansible-doc kubernetes.core.k8s
```

## 集成到KubePilot工作流

```bash
# 1. 安装collections（上述步骤）
./install-ansible-collections-offline.sh

# 2. 配置SSH互信
ansible-playbook -i inventory/k8s01/inventory.ini ssh_trust.yml

# 3. 部署Kubernetes集群
ansible-playbook -i inventory/k8s01/inventory.ini cluster.yml
```

## 所需Collections清单

| Collection | Version | 用途 | 关键模块 |
|------------|---------|------|----------|
| `ansible.posix` | 2.1.0+ | 系统管理 | `selinux`, `firewalld`, `mount` |
| `community.general` | 11.0.0+ | 通用工具 | `pam_limits`, `timezone`, `ufw` |
| `kubernetes.core` | 6.0.0+ | K8s管理 | `k8s`, `helm` |
| `community.docker` | 4.0.0+ | 容器管理 | `docker_container`, `docker_image` |
| `community.crypto` | 3.0.0+ | 证书管理 | SSL/TLS相关模块 |

## 故障排除

### 常见问题

**问题1: ansible-galaxy命令不存在**
```bash
# 解决方案
sudo dnf install ansible-core  # RHEL系列
sudo apt install ansible-core  # Debian系列
```

**问题2: 权限错误**
```bash
# 解决方案：使用sudo安装到系统位置
sudo ./install-ansible-collections-offline.sh
```

**问题3: Collection版本冲突**
```bash
# 解决方案：强制重新安装
cd ansible-collections/
ansible-galaxy collection install *.tar.gz --force
```

**问题4: 模块找不到**
```bash
# 检查collection是否正确安装
ansible-galaxy collection list | grep community.general

# 重新安装特定collection
ansible-galaxy collection install community-general-*.tar.gz --force
```

### 调试模式
```bash
# 使用详细输出模式安装
ansible-galaxy collection install *.tar.gz -vvv
```

## 自动化脚本

KubePilot提供了完整的自动化脚本：

1. **prepare-offline-collections.sh** - 在线环境准备脚本
2. **install-ansible-collections-offline.sh** - 离线环境安装脚本
3. **setup-ansible.sh** - 在线环境一键安装脚本

## 最佳实践

### 版本管理
- 🔒 使用固定版本号避免兼容性问题
- 📝 记录每次部署使用的collection版本
- 🔄 定期更新collections以获得安全修复

### 安全考虑
- ✅ 始终验证文件校验和
- 🔐 在安全环境中准备离线包
- 📋 审核collection内容和权限

### 存储管理
- 💾 保留多个版本的离线包
- 🗂️  按日期/版本组织文件结构
- 📊 监控存储空间使用

## 企业级部署建议

### 内部仓库
考虑建立内部Ansible Galaxy镜像：
```bash
# 企业可以建立内部pypi/galaxy镜像
ansible-galaxy collection install -s http://internal-galaxy.company.com
```

### 批量部署
```bash
# 使用配置管理工具批量安装
for host in $(cat hosts.txt); do
    scp kubepilot-collections.tar.gz $host:/tmp/
    ssh $host "cd /tmp && tar -xzf kubepilot-collections.tar.gz && ./install-ansible-collections-offline.sh"
done
```

### 合规性
- 📄 记录所有使用的开源组件
- ⚖️  确保符合企业开源使用政策
- 🔍 定期进行安全扫描

---

通过这个完整的离线安装方案，KubePilot确保了在完全隔离的环境中也能顺利部署Kubernetes集群，满足了企业级安全和合规要求。
