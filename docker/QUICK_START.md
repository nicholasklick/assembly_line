# Docker Quick Start Guide

## 🚀 Deploy KodeCD with Docker in 5 Minutes

### Local Development

```bash
# 1. Clone repository
git clone https://github.com/yourusername/kodecd.git
cd kodecd/assembly_line/docker

# 2. Copy and edit configuration
cp .env.example .env

# Generate secrets
echo "SECRET_KEY_BASE=$(openssl rand -hex 64)" >> .env
echo "RUNNER_TOKEN=$(openssl rand -hex 32)" >> .env

# 3. Install and start
./kodecd-docker install

# 4. Access at http://localhost
```

### Production (Digital Ocean / EC2)

```bash
# 1. Launch Ubuntu 22.04 server (4GB RAM minimum)

# 2. Install Docker
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER
# Log out and back in

# 3. Clone and setup
git clone https://github.com/yourusername/kodecd.git
cd kodecd/assembly_line/docker

# 4. Configure
cp .env.example .env
vim .env

# Update these values:
# - EXTERNAL_URL=https://kodecd.yourdomain.com
# - SECRET_KEY_BASE (generate with: openssl rand -hex 64)
# - RUNNER_TOKEN (generate with: openssl rand -hex 32)
# - POSTGRES_PASSWORD=secure_password

# 5. Install
./kodecd-docker install

# 6. Access at http://your-server-ip
```

## 📋 Essential Commands

```bash
# Start services
./kodecd-docker start

# Stop services
./kodecd-docker stop

# View logs
./kodecd-docker logs web

# Check status
./kodecd-docker status

# Open Rails console
./kodecd-docker console

# Backup
./kodecd-docker backup

# Update
./kodecd-docker update
```

## 🔧 Configuration Files

File | Purpose
-----|--------
`.env` | Docker Compose environment
`config/kodecd.env` | Application settings
`config/runner-config.toml` | Runner configuration
`templates/kodecd.conf` | Nginx configuration

## 🐳 Services

Service | Container | Port
--------|-----------|-----
Web App | kodecd-web | 3000
Nginx | kodecd-nginx | 80, 443
PostgreSQL | kodecd-postgres | 5432
Redis | kodecd-redis | 6379
Sidekiq | kodecd-sidekiq | -
Runner | kodecd-runner | -

## 🔒 Enable HTTPS

### Option 1: Reverse Proxy (Recommended)

Use Traefik, Caddy, or external nginx with Let's Encrypt.

### Option 2: Self-Signed Certificate

```bash
# Generate certificate
mkdir -p ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/kodecd.key \
  -out ssl/kodecd.crt \
  -subj "/CN=localhost"

# Update docker-compose.yml to mount ssl directory
# Uncomment HTTPS server in templates/kodecd.conf

# Restart
./kodecd-docker restart nginx
```

### Option 3: Certbot (Production)

```bash
# Install certbot
sudo apt-get install certbot

# Generate certificate
sudo certbot certonly --standalone -d kodecd.yourdomain.com

# Copy certificates
mkdir -p ssl
sudo cp /etc/letsencrypt/live/kodecd.yourdomain.com/fullchain.pem ssl/kodecd.crt
sudo cp /etc/letsencrypt/live/kodecd.yourdomain.com/privkey.pem ssl/kodecd.key

# Uncomment HTTPS server in templates/kodecd.conf
# Restart nginx
./kodecd-docker restart nginx
```

## 🛠️ Troubleshooting

Problem | Solution
--------|----------
Port 80 in use | Change `HTTP_PORT=8080` in .env
Cannot connect | Check firewall: `sudo ufw allow 80,443/tcp`
Database error | Check logs: `./kodecd-docker logs postgres`
Out of memory | Increase Docker memory to 4GB+
Runner not working | Check: `./kodecd-docker logs runner`

## 📦 What Gets Installed

- ✅ Rails Application (Puma web server)
- ✅ Sidekiq (Background jobs)
- ✅ PostgreSQL 16 (Database)
- ✅ Redis 7 (Cache & queue)
- ✅ Nginx (Reverse proxy)
- ✅ Runner (CI/CD executor)
- ✅ Health checks
- ✅ Auto-restart

## 🌐 Supported Platforms

- ✅ Linux (any distribution with Docker)
- ✅ macOS (Docker Desktop)
- ✅ Windows (Docker Desktop with WSL2)
- ✅ Cloud: AWS, GCP, Azure, Digital Ocean
- ✅ VPS: Linode, Vultr, Hetzner

## 💡 Production Tips

1. **Use a domain name** instead of IP address
2. **Enable SSL/HTTPS** for security
3. **Set strong passwords** for database and secrets
4. **Regular backups**: `./kodecd-docker backup` (daily cron)
5. **Monitor resources**: `docker stats`
6. **Update regularly**: `./kodecd-docker update`
7. **Secure your server**: firewall, SSH keys, fail2ban

## 🔄 Daily Operations

```bash
# Morning check
./kodecd-docker status

# View overnight logs
./kodecd-docker logs --tail=100

# Create backup
./kodecd-docker backup

# Update (weekly)
./kodecd-docker update
```

## 📚 Next Steps

After installation:

1. Create admin account (first user to sign up)
2. Configure SMTP in `config/kodecd.env`
3. Set up domain and SSL
4. Create your first project
5. Configure CI/CD runner
6. Set up automated backups (cron)
7. Configure monitoring (optional)

See [README.md](README.md) for full documentation.

## 🆘 Getting Help

- Run `./kodecd-docker help` for command reference
- Check logs: `./kodecd-docker logs`
- GitHub Issues: https://github.com/yourusername/kodecd/issues
- Documentation: https://docs.kodecd.com
