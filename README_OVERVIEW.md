# KodeCD Assembly Line

> Complete deployment solutions for KodeCD

The Assembly Line provides multiple deployment options for running KodeCD in production or development environments.

## 📦 Deployment Options

### 1. Docker (Recommended for Quick Start)

**Location:** `docker/`

Deploy the complete KodeCD stack using Docker Compose. Perfect for:
- Local development
- Quick testing
- Single-server deployments
- Cloud VMs (Digital Ocean, AWS EC2, etc.)

```bash
cd docker/
./kodecd-docker install
```

**Features:**
- ✅ One-command installation
- ✅ All services containerized
- ✅ Easy backup and restore
- ✅ Portable across platforms
- ✅ Development and production ready

**Documentation:**
- [Docker README](docker/README.md)
- [Docker Quick Start](docker/QUICK_START.md)

---

### 2. Helm/Kubernetes (Recommended for Cloud-Native)

**Location:** `helm/`

Deploy KodeCD to Kubernetes clusters using Helm charts. Perfect for:
- Cloud-native deployments (AWS EKS, GCP GKE, Azure AKS)
- Auto-scaling production workloads
- Multi-tenant environments
- Container orchestration at scale

```bash
cd helm/
helm install kodecd ./kodecd --namespace kodecd
```

**Features:**
- ✅ Kubernetes-native deployment
- ✅ Horizontal auto-scaling (HPA)
- ✅ High availability
- ✅ Cloud provider integration
- ✅ GitOps ready

**Documentation:**
- [Helm README](helm/kodecd/README.md)
- [Helm Quick Start](helm/kodecd/QUICK_START.md)

---

### 3. Ansible (Recommended for VMs)

**Location:** `ansible/`

Deploy KodeCD directly to bare metal or VMs using Ansible automation. Perfect for:
- Production deployments
- Enterprise environments
- Multi-server setups
- Custom infrastructure

```bash
curl -sSL https://install.kodecd.com | sudo bash
```

**Features:**
- ✅ Native OS installation
- ✅ Systemd service management
- ✅ Optimized for performance
- ✅ Full system integration
- ✅ Professional operations

**Documentation:**
- [Ansible README](README.md)
- [Ansible Quick Start](QUICK_START.md)

---

## 🗂️ Directory Structure

```
assembly_line/
├── README_OVERVIEW.md          # This file
│
├── docker/                     # Docker deployment
│   ├── docker-compose.yml      # Container orchestration
│   ├── Dockerfile.web          # Web/Sidekiq image
│   ├── Dockerfile.runner       # Runner image
│   ├── kodecd-docker           # Management script
│   ├── .env.example            # Environment template
│   ├── config/                 # Configuration templates
│   ├── templates/              # Nginx configs
│   ├── scripts/                # Helper scripts
│   ├── README.md               # Full documentation
│   └── QUICK_START.md          # Quick guide
│
├── helm/                       # Kubernetes deployment
│   └── kodecd/                 # Helm chart
│       ├── Chart.yaml          # Chart metadata
│       ├── values.yaml         # Default values
│       ├── values-production.yaml  # Production values
│       ├── templates/          # Kubernetes manifests
│       │   ├── deployment-web.yaml
│       │   ├── deployment-sidekiq.yaml
│       │   ├── deployment-runner.yaml
│       │   ├── service.yaml
│       │   ├── ingress.yaml
│       │   ├── configmap.yaml
│       │   ├── secret.yaml
│       │   └── pvc.yaml
│       ├── README.md           # Full documentation
│       └── QUICK_START.md      # Quick guide
│
└── ansible/                    # VM/Bare metal deployment
    ├── install.sh              # One-line installer
    ├── kodecd.conf.example     # Central config
    ├── site.yml                # Main playbook
    ├── tasks/                  # Ansible tasks
    ├── templates/              # Service templates
    ├── scripts/
    │   └── kodecd-ctl          # Management CLI
    ├── README.md               # Full documentation
    └── QUICK_START.md          # Quick guide
```

---

## 🎯 Choosing a Deployment Method

### Use Docker If:
- ✅ You want to get started quickly
- ✅ You're running on a development machine
- ✅ You need easy portability
- ✅ You're deploying to a single server
- ✅ You prefer containerized applications
- ✅ You want simplified backups

### Use Helm/Kubernetes If:
- ✅ You're running on Kubernetes (EKS, GKE, AKS)
- ✅ You need auto-scaling capabilities
- ✅ You want cloud-native deployment
- ✅ You need high availability
- ✅ You have multiple environments (dev/staging/prod)
- ✅ You want GitOps workflows

### Use Ansible If:
- ✅ You're deploying to production VMs
- ✅ You need maximum performance
- ✅ You have enterprise requirements
- ✅ You need multi-server deployments
- ✅ You want OS-level integration
- ✅ You have existing Ansible infrastructure

---

## 🚀 Quick Comparison

| Feature | Docker | Helm/Kubernetes | Ansible |
|---------|--------|-----------------|---------|
| **Installation Time** | ~5 minutes | ~10 minutes | ~10-15 minutes |
| **Complexity** | Low | Medium-High | Medium |
| **Performance** | Good | Excellent | Excellent |
| **Resource Usage** | Higher | Medium | Lower |
| **Isolation** | Complete | Complete (pods) | Process-level |
| **Scalability** | Manual | Auto-scaling | Manual |
| **High Availability** | Limited | Built-in | Manual setup |
| **Backup** | Docker volumes | PVC snapshots | File system |
| **Updates** | `./kodecd-docker update` | `helm upgrade` | `sudo kodecd-ctl upgrade` |
| **Best For** | Development, Testing | Cloud Production | VM Production |

---

## 📚 Common Use Cases

### Local Development
```bash
# Use Docker
cd assembly_line/docker/
./kodecd-docker install
```

### Production Single Server
```bash
# Option 1: Docker (easier)
cd assembly_line/docker/
./kodecd-docker install

# Option 2: Ansible (better performance)
curl -sSL https://install.kodecd.com | sudo bash
```

### Production on Kubernetes
```bash
# Use Helm for cloud-native deployment
cd assembly_line/helm/
helm install kodecd ./kodecd \
  --namespace kodecd \
  -f values-production.yaml
```

### Production Multi-Server
```bash
# Use Ansible with inventory
cd assembly_line/ansible/
# Configure inventory
ansible-playbook -i production site.yml
```

---

## 🔧 What Gets Installed

Both methods install the same components:

Component | Description
----------|------------
**Web** | Rails application (Puma)
**Sidekiq** | Background job processor
**PostgreSQL** | Database server
**Redis** | Cache and job queue
**Nginx** | Reverse proxy
**Runner** | CI/CD job executor

---

## 📖 Getting Started

### Docker Installation

1. **Install Docker**
   ```bash
   curl -fsSL https://get.docker.com | sh
   ```

2. **Clone Repository**
   ```bash
   git clone https://github.com/nicholasklick/assembly_line.git
   cd assembly_line/docker
   ```

3. **Configure**
   ```bash
   cp .env.example .env
   vim .env  # Update configuration
   ```

4. **Install**
   ```bash
   ./kodecd-docker install
   ```

5. **Access**
   ```
   http://localhost
   ```

### Helm/Kubernetes Installation

1. **Create Namespace**
   ```bash
   kubectl create namespace kodecd
   ```

2. **Generate Secrets**
   ```bash
   export SECRET_KEY_BASE=$(openssl rand -hex 64)
   export RUNNER_TOKEN=$(openssl rand -hex 32)
   ```

3. **Install Chart**
   ```bash
   cd assembly_line/helm
   helm install kodecd ./kodecd \
     --namespace kodecd \
     --set secrets.secretKeyBase=$SECRET_KEY_BASE \
     --set secrets.runnerToken=$RUNNER_TOKEN
   ```

4. **Access**
   ```bash
   kubectl port-forward -n kodecd svc/kodecd-web 8080:80
   # Or via Ingress: https://your-domain.com
   ```

### Ansible Installation

1. **Run Installer**
   ```bash
   curl -sSL https://install.kodecd.com | sudo bash
   ```

2. **Configure**
   ```bash
   sudo vim /etc/kodecd/kodecd.conf
   ```

3. **Reconfigure**
   ```bash
   sudo kodecd-ctl reconfigure
   ```

4. **Access**
   ```
   http://your-server-ip
   ```

---

## 🛠️ Management

### Docker Commands

```bash
# Service management
./kodecd-docker start|stop|restart|status

# Logs
./kodecd-docker logs [service]

# Console
./kodecd-docker console

# Backup
./kodecd-docker backup

# Update
./kodecd-docker update
```

### Helm/Kubernetes Commands

```bash
# Check status
kubectl get pods -n kodecd

# Logs
kubectl logs -n kodecd -l app.kubernetes.io/component=web -f

# Console
kubectl exec -it -n kodecd deployment/kodecd-web -- bundle exec rails console

# Upgrade
helm upgrade kodecd ./kodecd -n kodecd

# Backup
kubectl exec -it -n kodecd deployment/kodecd-postgresql-0 -- pg_dump -U kodecd
```

### Ansible Commands

```bash
# Service management
sudo kodecd-ctl start|stop|restart|status

# Logs
sudo kodecd-ctl tail [service]

# Console
sudo kodecd-ctl console

# Backup
sudo kodecd-ctl backup

# Update
sudo kodecd-ctl upgrade
```

---

## 🔒 Security Considerations

### Docker
- Change default passwords in `.env`
- Use external reverse proxy for SSL (Traefik, Caddy)
- Limit exposed ports
- Regular updates: `./kodecd-docker update`

### Helm/Kubernetes
- Use network policies for isolation
- Enable RBAC and pod security policies
- Configure SSL with cert-manager
- Regular updates: `helm upgrade kodecd`
- Use secrets management (Sealed Secrets, External Secrets)

### Ansible
- Configure firewall (UFW/iptables)
- Setup SSL with Let's Encrypt
- Secure SSH (key-based auth)
- Regular updates: `sudo kodecd-ctl upgrade`

---

## 📊 Resource Requirements

### Minimum
- **CPU:** 2 cores
- **RAM:** 4 GB
- **Disk:** 20 GB
- **OS:** Linux, macOS, Windows (Docker)

### Recommended
- **CPU:** 4+ cores
- **RAM:** 8+ GB
- **Disk:** 50+ GB SSD
- **OS:** Ubuntu 22.04, Debian 12

---

## 🆘 Support

- **Documentation:** [docs.kodecd.com](https://docs.kodecd.com)
- **Issues:** [GitHub Issues](https://github.com/nicholasklick/assembly_line/issues)
- **Community:** [KodeCD Slack](https://kodecd.slack.com)
- **Email:** support@kodecd.com

---

## 📝 License

See LICENSE file in the repository root.

---

## 🎓 Additional Resources

- [KodeCD Documentation](https://docs.kodecd.com)
- [Docker Documentation](https://docs.docker.com)
- [Ansible Documentation](https://docs.ansible.com)
- [Production Deployment Guide](https://docs.kodecd.com/deployment)
- [Troubleshooting Guide](https://docs.kodecd.com/troubleshooting)
