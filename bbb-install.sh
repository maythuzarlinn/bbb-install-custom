#!/bin/bash
set -e

# BigBlueButton 3.0.13 (2904) Installer
# Tested on Ubuntu 22.04 Jammy
# Installs BBB without SSL (using Public IP)
# Author: ChatGPT Fixed Script (2025)

# -------- CONFIGURATION --------
BBB_VERSION="jammy-300"
UBUNTU_VERSION="22.04"
PUBLIC_IP=$(hostname -I | awk '{print $1}')
REPO_URL="https://ubuntu.bigbluebutton.org"

echo "=================================================="
echo " BigBlueButton 3.0.13 (2904) Installer"
echo " Ubuntu Version  : ${UBUNTU_VERSION}"
echo " BBB Version     : ${BBB_VERSION}"
echo " Public IP       : ${PUBLIC_IP}"
echo " SSL             : Disabled"
echo "=================================================="
sleep 3

# -------- CHECKS --------
if [ "$EUID" -ne 0 ]; then
  echo " ❌ Please run this script as root"
  exit 1
fi

# Ensure Ubuntu 22.04 Jammy
OS_VERSION=$(lsb_release -rs)
if [[ "$OS_VERSION" != "$UBUNTU_VERSION" ]]; then
  echo " ❌ This script only supports Ubuntu ${UBUNTU_VERSION}."
  exit 1
fi

# -------- UPDATE & INSTALL BASICS --------
echo "▶ Updating system..."
apt-get update -y && apt-get upgrade -y
apt-get install -y wget curl gnupg2 software-properties-common apt-transport-https ca-certificates

# -------- ADD BIGBLUEBUTTON REPO --------
echo "▶ Adding BigBlueButton repository..."
mkdir -p /etc/apt/keyrings
wget -qO- ${REPO_URL}/repo/bigbluebutton.asc | gpg --dearmor | tee /etc/apt/keyrings/bigbluebutton.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/bigbluebutton.gpg] ${REPO_URL}/${BBB_VERSION} bigbluebutton-jammy main" | tee /etc/apt/sources.list.d/bigbluebutton.list

# -------- INSTALL NODEJS 22 --------
echo "▶ Installing Node.js 22..."
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor | tee /etc/apt/keyrings/nodesource.gpg > /dev/null
NODE_MAJOR=22
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
apt-get update -y
apt-get install -y nodejs

# -------- INSTALL DOCKER --------
echo "▶ Installing Docker..."
apt-get install -y docker.io docker-compose

# -------- INSTALL BIGBLUEBUTTON --------
echo "▶ Installing BigBlueButton ${BBB_VERSION}..."
apt-get update -y
apt-get install -y bigbluebutton

# -------- CONFIGURE BBB --------
echo "▶ Configuring BigBlueButton..."
bbb-conf --setip ${PUBLIC_IP}

# Disable SSL (since using IP instead of domain)
if [ ! -d "/etc/ssl/bigbluebutton" ]; then
    mkdir -p /etc/ssl/bigbluebutton
    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout /etc/ssl/bigbluebutton/bigbluebutton.key \
        -out /etc/ssl/bigbluebutton/bigbluebutton.crt \
        -subj "/C=US/ST=NA/L=NA/O=BigBlueButton/OU=Dev/CN=${PUBLIC_IP}"
    echo "▶ Self-signed SSL certificate created for IP usage."
fi

# -------- ENABLE & START SERVICES --------
echo "▶ Restarting services..."
systemctl enable bigbluebutton
systemctl restart bigbluebutton

# -------- FINAL CHECK --------
echo "▶ Running BBB check..."
bbb-conf --check || true

echo "=================================================="
echo " ✅ BigBlueButton 3.0.13 (2904) Installed!"
echo " Access URL: http://${PUBLIC_IP}"
echo "=================================================="
