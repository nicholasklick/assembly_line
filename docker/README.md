# KodeCD Docker Deployment

> Deploy the complete KodeCD stack with Docker Compose

## 🚀 Quick Start

### Prerequisites

- Docker 20.10+
- Docker Compose 2.0+ (or docker-compose 1.29+)
- 4GB+ RAM
- 20GB+ disk space

### One-Command Install

```bash
# Clone the repository
git clone https://github.com/nicholasklick/assembly_line.git
cd assembly_line/docker

# Install and start
./kodecd-docker install

# Access at http://localhost
```

## 📋 Installation Steps

### 1. Clone Repository

```bash
git clone https://github.com/nicholasklick/assembly_line.git
cd assembly_line/docker
```

### 2. Configure Environment

```bash
# Copy environment template
cp .env.example .env

# Edit configuration
vim .env
```

**Required settings:**

```bash
# Generate secret key: openssl rand -hex 64
SECRET_KEY_BASE=your_generated_secret_here

# Generate runner token: openssl rand -hex 32
RUNNER_TOKEN=your_runner_token_here

# Set external URL
EXTERNAL_URL=http://localhost

# Database password
POSTGRES_PASSWORD=secure_password_here
```

### 3. Install and Start

```bash
# Install (first time only)
./kodecd-docker install

# Or manually:
docker-compose up -d
docker-compose exec web bundle exec rails db:create db:schema:load db:seed
```

### 4. Access KodeCD

Open your browser to:
```
http://localhost
```

Create your admin account on first visit.

## 🎛️ Management Commands

The `kodecd-docker` script provides easy management:

### Service Management

```bash
# Start all services
./kodecd-docker start

# Stop all services
./kodecd-docker stop

# Restart all services
./kodecd-docker restart

# Check status
./kodecd-docker status
```

### Logs

```bash
# View all logs
./kodecd-docker logs

# View specific service logs
./kodecd-docker logs web
./kodecd-docker logs sidekiq
./kodecd-docker logs runner
./kodecd-docker logs nginx
```

### Console Access

```bash
# Open Rails console
./kodecd-docker console

# Open PostgreSQL console
./kodecd-docker db-console

# Open shell in a container
./kodecd-docker shell web
./kodecd-docker shell postgres
```

### Database Management

```bash
# Run migrations
./kodecd-docker db-migrate

# Seed database
./kodecd-docker db-seed
```

### Backup & Restore

```bash
# Create backup
./kodecd-docker backup

# Restore from backup
./kodecd-docker restore backups/kodecd_backup_20250101_120000.tar.gz
```

### Updates

```bash
# Update to latest version
./kodecd-docker update
```

## 📁 Services Architecture

The docker-compose stack includes:

| Service | Container | Description | Port |
|---------|-----------|-------------|------|
| **web** | kodecd-web | Rails application (Puma) | 3000 |
| **sidekiq** | kodecd-sidekiq | Background job processor | - |
| **runner** | kodecd-runner | CI/CD job executor | - |
| **postgres** | kodecd-postgres | PostgreSQL 16 database | 5432 |
| **redis** | kodecd-redis | Redis cache & queue | 6379 |
| **nginx** | kodecd-nginx | Reverse proxy | 80, 443 |

## 📂 Directory Structure

```
assembly_line/docker/
├── docker-compose.yml          # Main compose file
├── Dockerfile.web              # Web/Sidekiq image
├── Dockerfile.runner           # Runner image
├── .env.example                # Environment template
├── kodecd-docker               # Management script
├── config/
│   ├── kodecd.env.example      # App config template
│   └── runner-config.toml.example
├── templates/
│   ├── nginx.conf              # Nginx main config
│   └── kodecd.conf             # Site configuration
├── scripts/
│   └── runner.sh               # Runner startup script
└── backups/                    # Backup directory
```

## 🔧 Configuration

### Environment Variables (.env)

The `.env` file controls the Docker Compose stack:

```bash
# External URL
EXTERNAL_URL=http://localhost
EXTERNAL_HOST=localhost

# Security
SECRET_KEY_BASE=your_secret_key
RUNNER_TOKEN=your_runner_token

# Database
POSTGRES_USER=kodecd
POSTGRES_PASSWORD=secure_password
POSTGRES_DB=kodecd_production

# Redis
REDIS_PASSWORD=

# Ports
HTTP_PORT=80
HTTPS_PORT=443
WEB_PORT=3000

# Runner
RUNNER_CONCURRENT_JOBS=4
```

### Application Config (config/kodecd.env)

Application-level settings:

```bash
# SMTP for emails
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=notifications@example.com
SMTP_PASSWORD=your_password

# Feature flags
FEATURES_TEAMS_ENABLED=true
FEATURES_WIKI_ENABLED=true

# Storage paths (container paths)
GIT_DATA_DIR=/var/opt/kodecd/git-data
ARTIFACTS_DIR=/var/opt/kodecd/artifacts
```

## 🔒 SSL/HTTPS Setup

### Option 1: Reverse Proxy (Recommended)

Use an external reverse proxy (Traefik, Caddy, nginx) for SSL:

```yaml
# docker-compose.override.yml
version: '3.8'
services:
  nginx:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.kodecd.rule=Host(`kodecd.example.com`)"
      - "traefik.http.routers.kodecd.tls.certresolver=letsencrypt"
```

### Option 2: Self-Signed Certificate

```bash
# Generate self-signed certificate
mkdir -p ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/kodecd.key \
  -out ssl/kodecd.crt

# Update docker-compose.yml
volumes:
  - ./ssl:/etc/nginx/ssl:ro
```

Then uncomment the HTTPS server block in `templates/kodecd.conf`.

### Option 3: Let's Encrypt (Manual)

```bash
# Install certbot
apt-get install certbot

# Generate certificate
certbot certonly --standalone -d kodecd.example.com

# Copy certificates
cp /etc/letsencrypt/live/kodecd.example.com/fullchain.pem ssl/kodecd.crt
cp /etc/letsencrypt/live/kodecd.example.com/privkey.pem ssl/kodecd.key
```

## 🐳 Docker Volumes

Persistent data is stored in Docker volumes:

| Volume | Purpose | Size |
|--------|---------|------|
| `postgres-data` | Database files | ~5GB |
| `redis-data` | Redis persistence | ~1GB |
| `git-data` | Git repositories | Variable |
| `artifacts-data` | Build artifacts | Variable |
| `cache-data` | Runner cache | Variable |
| `storage-data` | ActiveStorage files | Variable |

### Backing Up Volumes

```bash
# Backup all volumes
docker run --rm \
  -v kodecd_git-data:/git-data \
  -v kodecd_artifacts-data:/artifacts \
  -v $(pwd)/backup:/backup \
  alpine tar -czf /backup/volumes.tar.gz /git-data /artifacts

# Restore volumes
docker run --rm \
  -v kodecd_git-data:/git-data \
  -v kodecd_artifacts-data:/artifacts \
  -v $(pwd)/backup:/backup \
  alpine tar -xzf /backup/volumes.tar.gz -C /
```

## 🔍 Troubleshooting

### Check Service Status

```bash
./kodecd-docker status
```

### View Logs

```bash
# All services
./kodecd-docker logs

# Specific service
./kodecd-docker logs web

# Follow logs
docker-compose logs -f web
```

### Common Issues

#### Port Already in Use

```bash
# Check what's using port 80
lsof -i :80

# Change port in .env
HTTP_PORT=8080
```

#### Database Connection Error

```bash
# Check PostgreSQL logs
./kodecd-docker logs postgres

# Verify database is ready
docker-compose exec postgres pg_isready -U kodecd
```

#### Permission Issues

```bash
# Fix volume permissions
docker-compose exec web chown -R kodecd:kodecd /var/opt/kodecd
```

#### Out of Memory

```bash
# Increase Docker memory limit
# Docker Desktop: Settings > Resources > Memory: 4GB+

# Check memory usage
docker stats
```

#### Runner Not Picking Up Jobs

```bash
# Check runner logs
./kodecd-docker logs runner

# Verify runner configuration
./kodecd-docker shell runner
cat /etc/kodecd-runner/config.toml

# Verify Docker socket access
docker-compose exec runner docker ps
```

## 🚀 Production Deployment

### Digital Ocean / VPS

```bash
# 1. Launch Ubuntu 22.04 droplet (4GB RAM minimum)

# 2. Install Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# 3. Clone and configure
git clone https://github.com/nicholasklick/assembly_line.git
cd assembly_line/docker
cp .env.example .env
vim .env  # Update configuration

# 4. Install
./kodecd-docker install

# 5. Configure domain
# Point DNS A record to server IP
# Update EXTERNAL_URL in .env
# Setup SSL (see SSL section)
```

### AWS EC2

```bash
# Use Amazon Linux 2 or Ubuntu 22.04
# Instance type: t3.medium (2 vCPU, 4GB RAM) minimum

# Follow same steps as Digital Ocean
# Configure security group:
#   - Port 80 (HTTP)
#   - Port 443 (HTTPS)
#   - Port 22 (SSH)
```

### Docker Swarm / Kubernetes

For container orchestration, see:
- Docker Swarm: `docker stack deploy`
- Kubernetes: Convert with `kompose convert`

## 📊 Monitoring

### Health Checks

All services include health checks:

```bash
# Check health status
docker-compose ps

# Manual health check
curl http://localhost/health
```

### Prometheus Metrics (Optional)

Enable Prometheus metrics in `config/kodecd.env`:

```bash
PROMETHEUS_ENABLED=true
PROMETHEUS_LISTEN_ADDRESS=localhost:9090
```

### Resource Usage

```bash
# Live stats
docker stats

# Disk usage
docker system df

# Volume sizes
docker volume ls -q | xargs -I {} docker volume inspect {} --format '{{ .Name }}: {{ .Mountpoint }}'
```

## 🔄 Upgrades

### Upgrade Process

```bash
# Automatic
./kodecd-docker update

# Manual
git pull
docker-compose pull
docker-compose build --no-cache
docker-compose up -d
./kodecd-docker db-migrate
```

### Rollback

```bash
# Stop current version
./kodecd-docker stop

# Restore from backup
./kodecd-docker restore backups/kodecd_backup_TIMESTAMP.tar.gz

# Or checkout previous version
git checkout v1.0.0
docker-compose up -d --build
```

## 🗑️ Uninstallation

```bash
# Stop and remove containers
./kodecd-docker clean

# Or manually
docker-compose down -v

# Remove images
docker rmi $(docker images 'kodecd*' -q)
```

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [KodeCD Documentation](https://docs.kodecd.com)
- [Issue Tracker](https://github.com/nicholasklick/assembly_line/issues)

## 🆘 Support

- GitHub Issues: https://github.com/nicholasklick/assembly_line/issues
- Community Slack: https://kodecd.slack.com
- Email: support@kodecd.com

## 📝 License

See LICENSE file in the repository root.
