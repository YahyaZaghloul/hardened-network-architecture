# Phase 4 — Services Configuration (Apache HTTPS + SSH)

## Overview

Phase 4 hardens the DMZ server (`pc-b`, `192.168.20.10`) by:
1. Installing and configuring **Apache2** with HTTP → HTTPS redirect
2. Generating a **self-signed SSL/TLS certificate** for `youssef-lab.local`
3. Hardening the **SSH daemon** (`sshd`)

---

## 4.1 Apache2 — HTTP & HTTPS

### Install Apache

```bash
sudo apt-get update
sudo apt-get install -y apache2
sudo a2enmod ssl headers rewrite
```

### Deploy Configuration

```bash
sudo cp server/apache/000-default.conf /etc/apache2/sites-available/
sudo cp server/apache/default-ssl.conf /etc/apache2/sites-available/
sudo a2ensite 000-default default-ssl
```

### Verify Apache is Running

```bash
sudo systemctl status apache2
# From Kali browser: http://192.168.20.10  → should redirect to HTTPS
# From Kali browser: https://192.168.20.10 → Apache default page with SSL
```

---

## 4.2 SSL Certificate — youssef-lab.local

### Certificate Details (as verified in Firefox certificate viewer)

| Field | Value |
|---|---|
| Common Name (CN) | `youssef-lab.local` |
| Country (C) | `EG` |
| State (ST) | `Giza` |
| Locality (L) | `Giza` |
| Organization (O) | `Faculty of Computers and Information` |
| Org Unit (OU) | `Cybersecurity` |
| Email | `admin@youssef-lab.local` |
| Valid From | Tue, 05 May 2026 |
| Valid Until | Wed, 05 May 2027 |
| Algorithm | RSA 2048-bit |
| Signature | SHA-256 with RSA Encryption |

### Generate Certificate

```bash
sudo bash server/ssl/gen-cert.sh
```

This creates:
- `/etc/ssl/certs/youssef-lab.local.crt`
- `/etc/ssl/private/youssef-lab.local.key`

### Verify Certificate in Browser

1. From Kali browser, navigate to `https://192.168.20.10`
2. Click the padlock → **View Certificate**
3. Confirm Subject Name matches table above

---

## 4.3 SSH Hardening

### Deploy Hardened Config

```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak   # backup
sudo cp server/ssh/sshd_config /etc/ssh/sshd_config
sudo cp server/ssh/banner.txt  /etc/ssh/banner.txt
sudo sshd -t                                              # validate
sudo systemctl reload ssh
```

### Key Hardening Options Applied

| Option | Value | Reason |
|---|---|---|
| `PermitRootLogin` | `no` | Prevent direct root access |
| `MaxAuthTries` | `3` | Limit brute-force attempts |
| `PasswordAuthentication` | `yes` | Lab environment |
| `X11Forwarding` | `no` | No GUI forwarding needed |
| `LoginGraceTime` | `60` | Disconnect slow/failed logins |
| `ClientAliveInterval` | `300` | Disconnect idle sessions |
| `LogLevel` | `VERBOSE` | Full auth logging for Snort detection |
| `Banner` | `/etc/ssh/banner.txt` | Legal warning on connect |

### Test SSH Access

```bash
# From pc-a (internal client) — should succeed
ssh ahmed@192.168.20.10

# From Kali (external) — allowed via iptables rule (port 22 forwarded)
ssh ahmed@192.168.20.10
```

> **Note:** Snort on the Gateway will detect repeated failed SSH attempts as `[1:1000007:1] Possible SSH Brute Force` if more than 5 connections occur within 60 seconds from the same source.
