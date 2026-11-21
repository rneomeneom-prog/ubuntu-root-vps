FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Update Ubuntu
RUN apt-get update && apt-get upgrade -y

# Essential system packages
RUN apt-get install -y \
    ca-certificates \
    curl \
    wget \
    git \
    gnupg \
    lsb-release \
    software-properties-common \
    apt-transport-https \
    locales \
    tzdata

# Python environment
RUN apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    python3-full \
    python-is-python3

# Development tools
RUN apt-get install -y \
    build-essential \
    gcc \
    g++ \
    make \
    cmake \
    pkg-config \
    default-jdk

# Node.js tools
RUN apt-get install -y \
    nodejs \
    npm

# SSH server
RUN apt-get install -y \
    openssh-server \
    openssl \
    sudo

# Terminal utilities
RUN apt-get install -y \
    nano \
    vim \
    neovim \
    screen \
    tmux \
    bash \
    zsh \
    htop \
    btop \
    tree \
    ncdu

# Networking utilities
RUN apt-get install -y \
    net-tools \
    iproute2 \
    iputils-ping \
    dnsutils \
    traceroute \
    nmap \
    socat \
    netcat-openbsd \
    rsync

# Hosting tools
RUN apt-get install -y \
    nginx \
    php-cli \
    php-curl \
    php-mbstring \
    php-xml

# File management
RUN apt-get install -y \
    zip \
    unzip \
    p7zip-full \
    tar \
    gzip \
    xz-utils

# Media utilities
RUN apt-get install -y \
    ffmpeg

# Additional system utilities
RUN apt-get install -y \
    cron \
    logrotate \
    jq \
    file \
    procps \
    psmisc \
    lsof \
    strace \
    less \
    man-db

# Clean package cache
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Prepare SSH
RUN mkdir -p /var/run/sshd /root/.ssh && \
    chmod 700 /root/.ssh

# SSH configuration
RUN printf '%s\n' \
    'Port 22' \
    'ListenAddress 0.0.0.0' \
    'PermitRootLogin yes' \
    'PasswordAuthentication yes' \
    'PubkeyAuthentication yes' \
    'UsePAM no' \
    'AllowTcpForwarding yes' \
    'X11Forwarding no' \
    'ClientAliveInterval 60' \
    'ClientAliveCountMax 3' \
    > /etc/ssh/sshd_config

# VPS startup script
RUN cat > /usr/local/bin/start-vps <<'EOF'
#!/bin/bash
set -e

if [ -z "${ROOT_PASSWORD:-}" ]; then
    echo "ERROR: Set ROOT_PASSWORD in Railway Variables."
    exit 1
fi

echo "root:${ROOT_PASSWORD}" | chpasswd

mkdir -p /var/run/sshd

ssh-keygen -A

echo "================================"
echo " Ubuntu 24.04 Root VPS"
echo "================================"
echo "Python: $(python3 --version)"
echo "Node: $(node --version)"
echo "Git: $(git --version)"
echo "Starting SSH server..."

exec /usr/sbin/sshd -D -e
EOF

RUN chmod +x /usr/local/bin/start-vps

EXPOSE 22

CMD ["/usr/local/bin/start-vps"]
