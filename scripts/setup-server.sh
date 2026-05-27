#!/usr/bin/env bash
# =============================================================================
# setup-server.sh — Full Server VM (pc-b) Provisioning Script
# OS: Ubuntu 24.04 LTS
# IP: 192.168.20.10/24 — DMZ network
# =============================================================================
# Configures:
#   1. Network interface (ens33 → VMnet3)
#   2. Apache2 with HTTP + HTTPS
#   3. Self-signed SSL certificate for youssef-lab.local
#   4. Hardened SSH daemon
# =============================================================================

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo "============================================================"
echo "  Hardened Network Architecture — Server (pc-b) Setup"
echo "============================================================"

# ---- Step 1: Network Configuration ----
echo ""
echo "[Phase 1] Configuring network interface..."
cp "$REPO_ROOT/server/netplan/00-server.yaml" /etc/netplan/00-server.yaml
chmod 600 /etc/netplan/00-server.yaml
netplan apply
echo "[+] Network config applied — IP: 192.168.20.10/24, GW: 192.168.20.1"

# ---- Step 2: Install Apache ----
echo ""
echo "[Phase 2] Installing Apache2..."
apt-get update -q
apt-get install -y apache2

# Enable required modules
a2enmod ssl headers rewrite
systemctl enable apache2

# Deploy vhost configs
cp "$REPO_ROOT/server/apache/000-default.conf" /etc/apache2/sites-available/000-default.conf
cp "$REPO_ROOT/server/apache/default-ssl.conf" /etc/apache2/sites-available/default-ssl.conf
a2ensite 000-default default-ssl
echo "[+] Apache configured."

# ---- Step 3: Generate SSL Certificate ----
echo ""
echo "[Phase 3] Generating self-signed SSL certificate..."
bash "$REPO_ROOT/server/ssl/gen-cert.sh"
echo "[+] SSL certificate installed."

# Restart Apache
systemctl restart apache2
echo "[+] Apache restarted with HTTPS enabled."

# Verify Apache
echo ""
echo "[*] Apache status:"
systemctl is-active apache2 && echo "    Apache is RUNNING" || echo "    Apache is NOT running"

# ---- Step 4: Harden SSH ----
echo ""
echo "[Phase 4] Hardening SSH server..."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
cp "$REPO_ROOT/server/ssh/sshd_config" /etc/ssh/sshd_config
cp "$REPO_ROOT/server/ssh/banner.txt"  /etc/ssh/banner.txt

# Validate config before reloading
sshd -t && systemctl reload ssh
echo "[+] SSH hardened and reloaded."

echo ""
echo "============================================================"
echo "  Server setup complete!"
echo ""
echo "  HTTP:  http://192.168.20.10     → redirects to HTTPS"
echo "  HTTPS: https://192.168.20.10    → youssef-lab.local"
echo "  SSH:   ssh ahmed@192.168.20.10"
echo "============================================================"
