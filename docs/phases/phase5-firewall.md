# Phase 5 — iptables Firewall

## Objective

Configure a **default-deny** packet filtering firewall on the Gateway VM using `iptables`, allowing only specific traffic to reach the DMZ server.

---

## Rules Applied

### Commands Executed (as shown in terminal)

```bash
# Flush all existing rules
sudo iptables -F

# Allow loopback traffic
sudo iptables -A INPUT -i lo -j ACCEPT

# Allow established/related connections through
sudo iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow HTTP (80) to DMZ server
sudo iptables -A FORWARD -p tcp -d 192.168.20.10 --dport 80 -j ACCEPT

# Allow HTTPS (443) to DMZ server
sudo iptables -A FORWARD -p tcp -d 192.168.20.10 --dport 443 -j ACCEPT

# Allow SSH (22) to DMZ server
sudo iptables -A FORWARD -p tcp -d 192.168.20.10 --dport 22 -j ACCEPT

# Set FORWARD default policy to DROP (default-deny)
sudo iptables -P FORWARD DROP

# Persist rules across reboots
sudo netfilter-persistent save
```

---

## Rule Table (Verified Output)

Output of `sudo iptables -L FORWARD -v -n --line-numbers`:

```
Chain FORWARD (policy DROP 0 packets, 0 bytes)
num  pkts bytes target  prot opt in  out  source       destination
1       0     0 ACCEPT   0   --  *   *    0.0.0.0/0    0.0.0.0/0    ctstate RELATED,ESTABLISHED
2       0     0 ACCEPT   6   --  *   *    0.0.0.0/0    192.168.20.10  tcp dpt:80
3       0     0 ACCEPT   6   --  *   *    0.0.0.0/0    192.168.20.10  tcp dpt:443
4       0     0 ACCEPT   6   --  *   *    0.0.0.0/0    192.168.20.10  tcp dpt:22
```

---

## Traffic Matrix

| Source | Destination | Port | Protocol | Action |
|---|---|---|---|---|
| Any | 192.168.20.10 | 80 | TCP | ✅ ACCEPT |
| Any | 192.168.20.10 | 443 | TCP | ✅ ACCEPT |
| Any | 192.168.20.10 | 22 | TCP | ✅ ACCEPT |
| Any | Any | Any | ICMP | ❌ DROP |
| Any | Any | Any | Any other | ❌ DROP |

---

## Apply via Script

```bash
sudo bash gateway/iptables/setup-firewall.sh
```

Or restore saved rules directly:

```bash
sudo cp gateway/iptables/rules.v4 /etc/iptables/rules.v4
sudo netfilter-persistent reload
```
