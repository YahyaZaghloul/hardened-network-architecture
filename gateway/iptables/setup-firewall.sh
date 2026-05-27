#!/usr/bin/env bash
# =============================================================================
# setup-firewall.sh — Gateway iptables Firewall Configuration
# =============================================================================
# Network:
#   LAN (Internal): 192.168.10.0/24  — interface ens33
#   DMZ (Server):   192.168.20.0/24  — interface ens34
#   WAN (External): 200.168.1.0/24   — interface ens39
#   Server IP:      192.168.20.10
# =============================================================================

set -e

echo "[*] Enabling IP forwarding..."
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p

echo "[*] Flushing existing rules..."
sudo iptables -F
sudo iptables -X
sudo iptables -t nat -F
sudo iptables -t nat -X

echo "[*] Setting default policies..."
sudo iptables -P INPUT   ACCEPT
sudo iptables -P OUTPUT  ACCEPT
sudo iptables -P FORWARD DROP       # Default-deny all forwarding

echo "[*] Configuring INPUT chain..."
# Allow loopback
sudo iptables -A INPUT -i lo -j ACCEPT
# Allow established/related inbound
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
# Drop invalid packets
sudo iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

echo "[*] Configuring FORWARD chain..."
# Allow established/related forward traffic
sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow HTTP (80) to DMZ server
sudo iptables -A FORWARD -p tcp -d 192.168.20.10 --dport 80  -j ACCEPT

# Allow HTTPS (443) to DMZ server
sudo iptables -A FORWARD -p tcp -d 192.168.20.10 --dport 443 -j ACCEPT

# Allow SSH (22) to DMZ server
sudo iptables -A FORWARD -p tcp -d 192.168.20.10 --dport 22  -j ACCEPT

echo "[*] Setting FORWARD default policy to DROP..."
sudo iptables -P FORWARD DROP

echo "[*] Saving rules with netfilter-persistent..."
sudo apt-get install -y iptables-persistent netfilter-persistent
sudo netfilter-persistent save

echo ""
echo "[+] Firewall configured. Current FORWARD chain:"
sudo iptables -L FORWARD -v -n --line-numbers

echo ""
echo "[+] Done."
