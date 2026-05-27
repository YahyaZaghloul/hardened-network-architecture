# Phase 6 — Snort IDS

## Objective

Deploy **Snort 2.9.20** as a Network Intrusion Detection System (IDS) on the Gateway VM, monitoring the internal LAN interface (`ens33`) for attacks.

---

## Installation

```bash
sudo apt-get update
sudo apt-get install -y snort
```

During installation, when asked for the HOME_NET, enter:
```
192.168.10.0/24,192.168.20.0/24
```

---

## Configuration

```bash
# Backup default config
sudo cp /etc/snort/snort.conf /etc/snort/snort.conf.bak

# Deploy project configs
sudo cp gateway/snort/snort.conf        /etc/snort/snort.conf
sudo cp gateway/snort/rules/local.rules /etc/snort/rules/local.rules
```

---

## Custom Detection Rules (`local.rules`)

| SID | Rule | Description |
|---|---|---|
| 1000001 | `flags:S; count 5/10s` | SYN Scan Detection |
| 1000002 | UDP threshold `count 5/10s` | UDP Scan Detection |
| 1000003 | `itype:8; count 5/10s` | ICMP Ping Sweep Detection |
| 1000004 | `flags:F` | FIN Scan Detection |
| 1000005 | `flags:0` | NULL Scan Detection |
| 1000006 | `flags:FPU` | XMAS Scan Detection |
| 1000007 | Port 22, `count 5/60s` | SSH Brute Force Detection |
| 1000008 | Port 80, `count 20/5s` | HTTP Flood / DoS |
| 1000009 | `flags:SF` | Nmap OS Fingerprint Probe |
| 1000010 | `count 15/5s` | General Port Scan |

---

## Running Snort

### Console Mode (interactive testing)
```bash
sudo snort -A console -q -c /etc/snort/snort.conf -i ens33
```

### Alert File Mode (production)
```bash
sudo snort -A fast -q -c /etc/snort/snort.conf -i ens33 -l /var/log/snort/ &
```

### View Live Alerts
```bash
sudo tail -f /var/log/snort/alert
```

---

## Verified Detections (from project screenshots)

### SSH Brute Force (from pc-a → pc-b via Hydra)
```
05/05-13:40:19.668645 [**] [1:1000007:1] Possible SSH Brute Force [**]
[Priority: 0] {TCP} 192.168.10.10:47920 -> 192.168.20.10:22
```

### ICMP Ping Sweep (from Kali → Server)
```
05/05-13:56:24.919328 [**] [1:1000003:1] ICMP Ping Sweep Detected [**]
[Priority: 0] {ICMP} 200.168.1.100 -> 192.168.20.10
```

### Nmap ICMP Probe (from Kali)
```
05/05-13:49:04.066110 [**] [1:469:3] ICMP PING NMAP [**]
[Classification: Attempted Information Leak] [Priority: 2]
{ICMP} 200.168.1.100 -> 192.168.20.10
```

---

## Systemd Service (optional — run at boot)

Create `/etc/systemd/system/snort.service`:

```ini
[Unit]
Description=Snort IDS
After=network.target

[Service]
Type=simple
ExecStart=/usr/sbin/snort -A fast -q -c /etc/snort/snort.conf -i ens33 -l /var/log/snort/
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable snort
sudo systemctl start snort
```
