#!/usr/bin/env bash
# =============================================================================
# setup-gateway.sh — Full Gateway VM Provisioning Script
# OS: Ubuntu 24.04 LTS
# =============================================================================
# Configures:
#   1. Network interfaces (ens33/ens34/ens39)
#   2. IP forwarding
#   3. iptables firewall (default-deny FORWARD)
#   4. Snort IDS 2.9.x
# =============================================================================

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo "============================================================"
echo "  Hardened Network Architecture — Gateway Setup"
echo "============================================================"

# ---- Step 1: Network Configuration ----
echo ""
echo "[Phase 1] Configuring network interfaces..."
cp "$REPO_ROOT/gateway/netplan/00-gateway.yaml" /etc/netplan/00-gateway.yaml
chmod 600 /etc/netplan/00-gateway.yaml
netplan apply
echo "[+] Network config applied."

# ---- Step 2: IP Forwarding ----
echo ""
echo "[Phase 2] Enabling IP forwarding..."
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i '/^#net.ipv4.ip_forward/s/^#//' /etc/sysctl.conf
sysctl -p
echo "[+] IP forwarding enabled."

# ---- Step 3: Firewall ----
echo ""
echo "[Phase 3] Setting up iptables firewall..."
apt-get install -y iptables-persistent netfilter-persistent

# Flush existing rules
iptables -F
iptables -X
iptables -t nat -F

# INPUT chain
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

# FORWARD chain — default deny
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -p tcp -d 192.168.20.10 --dport 80  -j ACCEPT
iptables -A FORWARD -p tcp -d 192.168.20.10 --dport 443 -j ACCEPT
iptables -A FORWARD -p tcp -d 192.168.20.10 --dport 22  -j ACCEPT
iptables -P FORWARD DROP

netfilter-persistent save
echo "[+] Firewall rules applied and saved."

# Verify
echo ""
echo "[*] FORWARD chain:"
iptables -L FORWARD -v -n --line-numbers

# ---- Step 4: Snort IDS ----
echo ""
echo "[Phase 4] Installing and configuring Snort IDS..."
apt-get install -y snort

# Backup and replace configs
cp /etc/snort/snort.conf /etc/snort/snort.conf.bak
cp "$REPO_ROOT/gateway/snort/snort.conf"         /etc/snort/snort.conf
cp "$REPO_ROOT/gateway/snort/rules/local.rules"  /etc/snort/rules/local.rules

# Create log directory
mkdir -p /var/log/snort
chown snort:snort /var/log/snort 2>/dev/null || true

echo "[+] Snort configured."
echo ""
echo "[*] To start Snort IDS (monitoring ens33 — Internal LAN):"
echo "    sudo snort -A console -q -c /etc/snort/snort.conf -i ens33"
echo ""
echo "============================================================"
echo "  Gateway setup complete!"
echo "  Verify with: bash scripts/verify.sh"
echo "============================================================"
