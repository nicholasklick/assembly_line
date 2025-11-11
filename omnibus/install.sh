#!/bin/bash
set -e

################################################################################
# KodeCD Complete Stack Installer
# Usage: curl -sSL https://install.kodecd.com | sudo bash
# or: wget -qO- https://install.kodecd.com | sudo bash
################################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
KODECD_VERSION="${KODECD_VERSION:-latest}"
INSTALL_DIR="/opt/kodecd"
CONFIG_DIR="/etc/kodecd"
DATA_DIR="/var/opt/kodecd"
LOG_DIR="/var/log/kodecd"
KODECD_USER="kodecd"
KODECD_GROUP="kodecd"

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        OS_VERSION=$VERSION_ID
    else
        log_error "Cannot detect operating system"
        exit 1
    fi

    log_info "Detected OS: $OS $OS_VERSION"
}

check_requirements() {
    log_info "Checking system requirements..."

    # Check CPU cores
    CPU_CORES=$(nproc)
    if [ "$CPU_CORES" -lt 2 ]; then
        log_warning "Recommended: 2+ CPU cores (detected: $CPU_CORES)"
    fi

    # Check RAM
    TOTAL_RAM=$(free -g | awk '/^Mem:/{print $2}')
    if [ "$TOTAL_RAM" -lt 4 ]; then
        log_warning "Recommended: 4GB+ RAM (detected: ${TOTAL_RAM}GB)"
    fi

    # Check disk space
    FREE_SPACE=$(df -BG / | awk 'NR==2{print $4}' | sed 's/G//')
    if [ "$FREE_SPACE" -lt 20 ]; then
        log_warning "Recommended: 20GB+ free disk space (detected: ${FREE_SPACE}GB)"
    fi

    log_success "System requirements check complete"
}

install_dependencies() {
    log_info "Installing system dependencies..."

    case "$OS" in
        ubuntu|debian)
            apt-get update
            apt-get install -y \
                curl \
                wget \
                git \
                build-essential \
                libssl-dev \
                libreadline-dev \
                zlib1g-dev \
                postgresql \
                postgresql-contrib \
                redis-server \
                nginx \
                certbot \
                python3-certbot-nginx \
                ansible \
                docker.io \
                docker-compose

            systemctl enable postgresql redis-server nginx docker
            systemctl start postgresql redis-server
            ;;

        centos|rhel|fedora)
            yum install -y epel-release
            yum install -y \
                curl \
                wget \
                git \
                gcc \
                make \
                openssl-devel \
                readline-devel \
                zlib-devel \
                postgresql-server \
                postgresql-contrib \
                redis \
                nginx \
                certbot \
                python3-certbot-nginx \
                ansible \
                docker \
                docker-compose

            postgresql-setup initdb
            systemctl enable postgresql redis nginx docker
            systemctl start postgresql redis
            ;;

        *)
            log_error "Unsupported OS: $OS"
            exit 1
            ;;
    esac

    log_success "Dependencies installed"
}

create_user() {
    log_info "Creating kodecd user..."

    if ! id -u $KODECD_USER > /dev/null 2>&1; then
        useradd --system --home-dir $INSTALL_DIR --shell /bin/bash $KODECD_USER
        log_success "User $KODECD_USER created"
    else
        log_info "User $KODECD_USER already exists"
    fi
}

create_directories() {
    log_info "Creating directories..."

    mkdir -p $INSTALL_DIR
    mkdir -p $CONFIG_DIR
    mkdir -p $DATA_DIR/{git-data,artifacts,cache,backups,tmp}
    mkdir -p $LOG_DIR

    chown -R $KODECD_USER:$KODECD_GROUP $INSTALL_DIR
    chown -R $KODECD_USER:$KODECD_GROUP $DATA_DIR
    chown -R $KODECD_USER:$KODECD_GROUP $LOG_DIR

    log_success "Directories created"
}

install_ruby() {
    log_info "Installing Ruby 3.4.2..."

    if command -v ruby > /dev/null && ruby -v | grep -q "3.4.2"; then
        log_info "Ruby 3.4.2 already installed"
        return
    fi

    # Install rbenv
    if [ ! -d "$INSTALL_DIR/.rbenv" ]; then
        git clone https://github.com/rbenv/rbenv.git $INSTALL_DIR/.rbenv
        git clone https://github.com/rbenv/ruby-build.git $INSTALL_DIR/.rbenv/plugins/ruby-build
    fi

    export PATH="$INSTALL_DIR/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"

    rbenv install 3.4.2 || true
    rbenv global 3.4.2

    log_success "Ruby installed"
}

install_nodejs() {
    log_info "Installing Node.js..."

    if command -v node > /dev/null && node -v | grep -q "v20"; then
        log_info "Node.js 20 already installed"
        return
    fi

    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y nodejs

    log_success "Node.js installed"
}

setup_database() {
    log_info "Setting up PostgreSQL database..."

    sudo -u postgres psql -c "CREATE USER kodecd WITH PASSWORD 'kodecd_password';" || true
    sudo -u postgres psql -c "CREATE DATABASE kodecd_production OWNER kodecd;" || true
    sudo -u postgres psql -c "ALTER USER kodecd CREATEDB;" || true

    log_success "Database configured"
}

download_kodecd() {
    log_info "Downloading KodeCD $KODECD_VERSION..."

    cd $INSTALL_DIR

    if [ "$KODECD_VERSION" = "latest" ]; then
        # Clone from git (for development)
        if [ ! -d ".git" ]; then
            git clone https://github.com/nicholasklick/assembly_line.git .
        else
            git pull
        fi
    else
        # Download release tarball
        wget -O kodecd.tar.gz "https://github.com/nicholasklick/assembly_line/archive/refs/tags/v${KODECD_VERSION}.tar.gz"
        tar -xzf kodecd.tar.gz --strip-components=1
        rm kodecd.tar.gz
    fi

    chown -R $KODECD_USER:$KODECD_GROUP $INSTALL_DIR

    log_success "KodeCD downloaded"
}

install_application() {
    log_info "Installing application dependencies..."

    cd $INSTALL_DIR

    # Install Ruby gems
    sudo -u $KODECD_USER bash -c "
        export PATH=\"$INSTALL_DIR/.rbenv/bin:\$PATH\"
        eval \"\$(rbenv init -)\"
        gem install bundler
        bundle install --deployment --without development test
    "

    # Install Node packages
    sudo -u $KODECD_USER npm --prefix frontend install

    log_success "Application dependencies installed"
}

generate_config() {
    log_info "Generating configuration..."

    cp $INSTALL_DIR/assembly_line/kodecd.conf.example $CONFIG_DIR/kodecd.conf

    # Generate secrets
    SECRET_KEY=$(openssl rand -hex 64)
    RUNNER_TOKEN=$(openssl rand -hex 32)
    DB_PASSWORD=$(openssl rand -hex 16)

    # Update config
    sed -i "s/CHANGE_ME_TO_RANDOM_STRING/$SECRET_KEY/" $CONFIG_DIR/kodecd.conf
    sed -i "s/CHANGE_ME_TO_SECURE_TOKEN/$RUNNER_TOKEN/" $CONFIG_DIR/kodecd.conf

    chmod 600 $CONFIG_DIR/kodecd.conf
    chown root:root $CONFIG_DIR/kodecd.conf

    log_success "Configuration generated"
}

setup_services() {
    log_info "Setting up systemd services..."

    # Run Ansible playbook to setup services
    cd $INSTALL_DIR/assembly_line/ansible
    ansible-playbook -i localhost, -c local site.yml

    log_success "Services configured"
}

run_migrations() {
    log_info "Running database migrations..."

    cd $INSTALL_DIR
    sudo -u $KODECD_USER bash -c "
        export PATH=\"$INSTALL_DIR/.rbenv/bin:\$PATH\"
        eval \"\$(rbenv init -)\"
        export RAILS_ENV=production
        bundle exec rails db:create
        bundle exec rails db:schema:load
        bundle exec rails db:seed
    "

    log_success "Database migrations complete"
}

start_services() {
    log_info "Starting services..."

    systemctl daemon-reload
    systemctl enable kodecd-web kodecd-sidekiq kodecd-runner
    systemctl start kodecd-web kodecd-sidekiq kodecd-runner nginx

    log_success "Services started"
}

print_success_message() {
    echo ""
    echo -e "${GREEN}=================================${NC}"
    echo -e "${GREEN}KodeCD Installation Complete!${NC}"
    echo -e "${GREEN}=================================${NC}"
    echo ""
    echo -e "Configuration file: ${BLUE}$CONFIG_DIR/kodecd.conf${NC}"
    echo -e "Installation directory: ${BLUE}$INSTALL_DIR${NC}"
    echo -e "Data directory: ${BLUE}$DATA_DIR${NC}"
    echo ""
    echo -e "Services:"
    echo -e "  • Web: ${BLUE}systemctl status kodecd-web${NC}"
    echo -e "  • Sidekiq: ${BLUE}systemctl status kodecd-sidekiq${NC}"
    echo -e "  • Runner: ${BLUE}systemctl status kodecd-runner${NC}"
    echo ""
    echo -e "Next steps:"
    echo -e "  1. Edit configuration: ${BLUE}sudo vim $CONFIG_DIR/kodecd.conf${NC}"
    echo -e "  2. Reconfigure: ${BLUE}sudo kodecd-ctl reconfigure${NC}"
    echo -e "  3. Access KodeCD at: ${BLUE}http://$(hostname -I | awk '{print $1}')${NC}"
    echo ""
    echo -e "Documentation: ${BLUE}https://docs.kodecd.com${NC}"
    echo ""
}

# Main installation flow
main() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   KodeCD Production Installer ${KODECD_VERSION}    ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""

    check_root
    detect_os
    check_requirements

    log_info "Starting installation..."

    install_dependencies
    create_user
    create_directories
    install_ruby
    install_nodejs
    setup_database
    download_kodecd
    install_application
    generate_config
    setup_services
    run_migrations
    start_services

    print_success_message
}

# Run installation
main "$@"
