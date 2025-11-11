# Quick Start Guide

## 🚀 Deploy KodeCD in 5 Minutes

### For Ubuntu/Debian

```bash
# Run the one-line installer
curl -sSL https://raw.githubusercontent.com/yourusername/kodecd/main/assembly_line/install.sh | sudo bash

# Edit configuration
sudo vim /etc/kodecd/kodecd.conf

# Update these values:
# - external_url
# - secret_key_base
# - database_password
# - runner_token
# - smtp settings (if using email)

# Reconfigure
sudo kodecd-ctl reconfigure

# Check status
sudo kodecd-ctl status

# Access at http://your-server-ip
```

### For Testing Locally (Digital Ocean / EC2)

```bash
# 1. Launch a VM (Ubuntu 22.04, 2GB RAM minimum)

# 2. SSH into the VM
ssh root@your-vm-ip

# 3. Run installer
curl -sSL https://raw.githubusercontent.com/yourusername/kodecd/main/assembly_line/install.sh | bash

# 4. Wait for installation (~5-10 minutes)

# 5. Access KodeCD
# http://your-vm-ip
```

## 📋 Post-Installation

### Set External URL

```bash
sudo vim /etc/kodecd/kodecd.conf
```

Change:
```conf
external_url = "https://kodecd.yourdomain.com"
```

Apply:
```bash
sudo kodecd-ctl reconfigure
```

### Configure SSL with Let's Encrypt

```bash
sudo vim /etc/kodecd/kodecd.conf
```

Add:
```conf
nginx_letsencrypt_enabled = true
nginx_letsencrypt_email = "admin@yourdomain.com"
```

Apply:
```bash
sudo kodecd-ctl reconfigure
```

### Test the Installation

```bash
# Check all services are running
sudo kodecd-ctl status

# View logs
sudo kodecd-ctl tail web

# Open Rails console
sudo kodecd-ctl console
```

## 🎯 Common Commands

```bash
# Service management
sudo kodecd-ctl start
sudo kodecd-ctl stop
sudo kodecd-ctl restart
sudo kodecd-ctl status

# Configuration
sudo kodecd-ctl reconfigure

# Logs
sudo kodecd-ctl tail web
sudo kodecd-ctl tail sidekiq
sudo kodecd-ctl tail runner

# Backup
sudo kodecd-ctl backup

# Upgrade
sudo kodecd-ctl upgrade
```

## 🔧 Manual Installation (Development)

If you want to install manually for development:

```bash
# Clone repository
cd /opt
sudo git clone https://github.com/yourusername/kodecd.git
cd kodecd

# Run setup scripts
sudo assembly_line/install.sh

# Or run individual steps:
sudo assembly_line/scripts/kodecd-ctl reconfigure
```

## 📦 What Gets Installed

Component | Location | Description
----------|----------|------------
Application | `/opt/kodecd` | Rails app, Runner, RPC
Configuration | `/etc/kodecd/kodecd.conf` | Main config file
Data | `/var/opt/kodecd/git-data` | Git repositories
Logs | `/var/log/kodecd/` | Application logs
Backups | `/var/opt/kodecd/backups/` | Backup files
Services | `/etc/systemd/system/kodecd-*.service` | Systemd services

## 🌐 Supported Platforms

- ✅ Ubuntu 20.04, 22.04, 24.04
- ✅ Debian 10, 11, 12
- ✅ CentOS 8, 9
- ✅ RHEL 8, 9
- ✅ Amazon Linux 2, 2023
- ✅ Rocky Linux 8, 9

## 💡 Tips

1. **Use a domain name** instead of IP address for `external_url`
2. **Enable Let's Encrypt** for automatic SSL certificates
3. **Configure email** for user notifications and password resets
4. **Set up backups** - run `sudo kodecd-ctl backup` daily via cron
5. **Monitor resources** - KodeCD needs at least 4GB RAM for production
6. **Secure your server** - configure firewall, SSH keys, and fail2ban

## 🆘 Troubleshooting

Problem | Solution
--------|----------
Services won't start | Check `sudo journalctl -u kodecd-web`
Can't access web UI | Check firewall: `sudo ufw allow 80,443/tcp`
Database errors | Check PostgreSQL: `sudo systemctl status postgresql`
Runner not picking up jobs | Check runner logs: `sudo kodecd-ctl tail runner`

## 📚 Next Steps

After installation:

1. Create admin account (first user to sign up)
2. Configure SMTP for email
3. Set up SSH keys for git operations
4. Create your first project
5. Configure CI/CD runners
6. Set up backups (cron job)

See [README.md](README.md) for full documentation.
