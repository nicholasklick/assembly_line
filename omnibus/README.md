# KodeCD Production Installer

> A complete package installer for deploying the full KodeCD stack to production servers

## 🚀 Quick Start

### One-Line Installation

```bash
curl -sSL https://install.kodecd.com | sudo bash
```

Or with wget:

```bash
wget -qO- https://install.kodecd.com | sudo bash
```

### What Gets Installed

The KodeCD installer automatically sets up:

- ✅ **Rails Application** (Puma web server)
- ✅ **Sidekiq** (Background job processor)
- ✅ **PostgreSQL** (Database)
- ✅ **Redis** (Cache & job queue)
- ✅ **Nginx** (Reverse proxy with SSL)
- ✅ **Runner** (CI/CD job executor)
- ✅ **Systemd Services** (Auto-start on boot)
- ✅ **Log Rotation** (Automated log management)

## 📋 System Requirements

### Minimum Requirements
- **OS**: Ubuntu 20.04+, Debian 10+, CentOS 8+, RHEL 8+
- **CPU**: 2 cores
- **RAM**: 4 GB
- **Disk**: 20 GB free space
- **Root Access**: Required for installation

### Recommended Requirements
- **CPU**: 4+ cores
- **RAM**: 8+ GB
- **Disk**: 50+ GB SSD
- **Network**: Static IP with DNS configured

## 🛠️ Installation Steps

### 1. Download and Run Installer

```bash
# Download the installer
curl -sSL https://github.com/nicholasklick/assembly_line/raw/main/install.sh -o install.sh

# Make it executable
chmod +x install.sh

# Run as root
sudo ./install.sh
```

### 2. Configure KodeCD

Edit the configuration file:

```bash
sudo vim /etc/kodecd/kodecd.conf
```

**Required settings to change:**

```conf
# Set your external URL
external_url = "https://kodecd.example.com"

# Generate secret key (run: openssl rand -hex 64)
secret_key_base = "YOUR_GENERATED_SECRET"

# Set database password
database_password = "SECURE_PASSWORD"

# Set runner token (run: openssl rand -hex 32)
runner_token = "YOUR_RUNNER_TOKEN"

# Configure SMTP for emails
smtp_address = "smtp.example.com"
smtp_username = "notifications@example.com"
smtp_password = "SMTP_PASSWORD"
```

### 3. Reconfigure and Start

```bash
# Apply configuration changes
sudo kodecd-ctl reconfigure

# Start services
sudo kodecd-ctl start

# Check status
sudo kodecd-ctl status
```

### 4. Access KodeCD

Open your browser and navigate to:
```
https://kodecd.example.com
```

Create your admin account on first visit.

## 🎛️ Management Commands

The `kodecd-ctl` command provides easy management:

### Service Management

```bash
# Start all services
sudo kodecd-ctl start

# Stop all services
sudo kodecd-ctl stop

# Restart all services
sudo kodecd-ctl restart

# Check status
sudo kodecd-ctl status
```

### Configuration

```bash
# Reconfigure after changing /etc/kodecd/kodecd.conf
sudo kodecd-ctl reconfigure
```

### Logs

```bash
# Tail web application logs
sudo kodecd-ctl tail web

# Tail sidekiq logs
sudo kodecd-ctl tail sidekiq

# Tail runner logs
sudo kodecd-ctl tail runner

# Tail nginx logs
sudo kodecd-ctl tail nginx
```

### Console Access

```bash
# Open Rails console
sudo kodecd-ctl console

# Open PostgreSQL console
sudo kodecd-ctl db-console
```

### Backup & Restore

```bash
# Create a backup
sudo kodecd-ctl backup

# Restore from backup
sudo kodecd-ctl restore /var/opt/kodecd/backups/kodecd_backup_20250101_120000.tar.gz
```

### Upgrades

```bash
# Upgrade to latest version
sudo kodecd-ctl upgrade
```

## 📁 Directory Structure

```
/opt/kodecd/              # Application installation
/etc/kodecd/              # Configuration files
  ├── kodecd.conf         # Main config file
  └── runner-config.toml  # Runner configuration
/var/opt/kodecd/          # Data directories
  ├── git-data/           # Git repositories
  ├── artifacts/          # Build artifacts
  ├── cache/              # Runner cache
  ├── backups/            # Backup files
  └── tmp/                # Temporary files
/var/log/kodecd/          # Log files
  ├── web.log             # Rails application logs
  ├── sidekiq.log         # Background job logs
  └── runner.log          # CI/CD runner logs
```

## 🔧 Configuration File Reference

### Essential Settings

```conf
# External URL (REQUIRED)
external_url = "https://kodecd.example.com"

# Secret key base (REQUIRED - generate with: openssl rand -hex 64)
secret_key_base = "CHANGE_ME"

# Database (REQUIRED)
database_password = "CHANGE_ME"

# Runner (REQUIRED for CI/CD)
runner_token = "CHANGE_ME"
```

### Database Settings

```conf
database_host = "localhost"
database_port = 5432
database_name = "kodecd_production"
database_username = "kodecd"
database_pool = 25
```

### Redis Settings

```conf
redis_host = "localhost"
redis_port = 6379
redis_password = ""  # Leave empty if no password
redis_db = 0
```

### Nginx Settings

```conf
nginx_enabled = true
nginx_listen_port = 80
nginx_listen_https_port = 443
nginx_client_max_body_size = "250m"  # For large git pushes

# SSL Certificate
nginx_ssl_certificate = "/path/to/cert.pem"
nginx_ssl_certificate_key = "/path/to/key.pem"

# Or use Let's Encrypt
nginx_letsencrypt_enabled = true
nginx_letsencrypt_email = "admin@example.com"
```

### Email Settings

```conf
mail_enabled = true
smtp_address = "smtp.gmail.com"
smtp_port = 587
smtp_username = "notifications@example.com"
smtp_password = "CHANGE_ME"
smtp_domain = "example.com"
smtp_authentication = "plain"
smtp_enable_starttls_auto = true
mail_from = "kodecd@example.com"
```

### Runner Settings

```conf
runner_enabled = true
runner_concurrent_jobs = 4
runner_executor = "docker"  # Options: docker, shell, kubernetes
```

### Performance Tuning

```conf
# Web workers
puma_workers = 2
puma_threads_min = 5
puma_threads_max = 5

# Background jobs
sidekiq_concurrency = 25
```

## 🔒 SSL/HTTPS Setup

### Option 1: Let's Encrypt (Recommended)

```conf
nginx_letsencrypt_enabled = true
nginx_letsencrypt_email = "admin@example.com"
```

Then reconfigure:
```bash
sudo kodecd-ctl reconfigure
```

### Option 2: Custom SSL Certificate

```conf
nginx_ssl_certificate = "/etc/ssl/certs/kodecd.crt"
nginx_ssl_certificate_key = "/etc/ssl/private/kodecd.key"
```

Place your certificate files in the specified paths, then reconfigure.

### Option 3: Self-Signed (Development Only)

The installer automatically generates a self-signed certificate if no certificate is provided.

## 🐳 Docker Runner Configuration

### Enable Docker Executor

```conf
runner_executor = "docker"
```

### Add kodecd user to docker group

```bash
sudo usermod -aG docker kodecd
sudo kodecd-ctl restart runner
```

### Verify Docker Access

```bash
sudo -u kodecd docker ps
```

## 🔍 Troubleshooting

### Check Service Status

```bash
sudo kodecd-ctl status
```

### View Logs

```bash
# Application logs
sudo kodecd-ctl tail web

# Check systemd logs
sudo journalctl -u kodecd-web -f
```

### Common Issues

#### Port Already in Use

```bash
# Check what's using port 3000
sudo lsof -i :3000

# Check what's using port 80
sudo lsof -i :80
```

#### Database Connection Issues

```bash
# Check PostgreSQL is running
sudo systemctl status postgresql

# Test database connection
sudo -u postgres psql kodecd_production
```

#### Permission Issues

```bash
# Fix ownership
sudo chown -R kodecd:kodecd /opt/kodecd
sudo chown -R kodecd:kodecd /var/opt/kodecd
sudo chown -R kodecd:kodecd /var/log/kodecd
```

## 🚀 Production Deployment Checklist

- [ ] Set strong `secret_key_base`
- [ ] Configure proper SSL certificates
- [ ] Set secure database password
- [ ] Configure SMTP for email notifications
- [ ] Set up automated backups
- [ ] Configure firewall (allow ports 80, 443, 22)
- [ ] Set up monitoring (consider Prometheus)
- [ ] Configure log rotation
- [ ] Test backup and restore procedure
- [ ] Set up DNS records
- [ ] Configure runner with appropriate concurrency
- [ ] Test git operations (push/pull)
- [ ] Verify CI/CD pipeline execution

## 📊 Monitoring

### Built-in Health Check

```bash
curl http://localhost:3000/health
```

### Systemd Status

```bash
sudo systemctl status kodecd-web kodecd-sidekiq kodecd-runner
```

### Resource Usage

```bash
# CPU and memory
htop

# Disk usage
df -h

# Process list
ps aux | grep kodecd
```

## 🔄 Upgrades

### Automatic Upgrade

```bash
sudo kodecd-ctl upgrade
```

This will:
1. Create a backup
2. Pull latest code
3. Update dependencies
4. Run database migrations
5. Restart services

### Manual Upgrade

```bash
cd /opt/kodecd
sudo -u kodecd git pull
sudo -u kodecd bundle install
sudo -u kodecd npm --prefix frontend install
sudo -u kodecd RAILS_ENV=production bundle exec rails db:migrate
sudo kodecd-ctl restart
```

## 🗑️ Uninstallation

```bash
# Stop all services
sudo kodecd-ctl stop

# Remove services
sudo systemctl disable kodecd-web kodecd-sidekiq kodecd-runner
sudo rm /etc/systemd/system/kodecd-*.service

# Remove application
sudo rm -rf /opt/kodecd

# Remove data (CAUTION: This deletes all your data!)
sudo rm -rf /var/opt/kodecd

# Remove config
sudo rm -rf /etc/kodecd

# Remove logs
sudo rm -rf /var/log/kodecd

# Remove user
sudo userdel kodecd
```

## 📚 Additional Resources

- [Documentation](https://docs.kodecd.com)
- [API Reference](https://docs.kodecd.com/api)
- [Community Forum](https://community.kodecd.com)
- [Issue Tracker](https://github.com/nicholasklick/assembly_line/issues)

## 🤝 Support

- GitHub Issues: https://github.com/nicholasklick/assembly_line/issues
- Community Slack: https://kodecd.slack.com
- Email: support@kodecd.com

## 📝 License

See LICENSE file in the repository root.
