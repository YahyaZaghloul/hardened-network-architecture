# 🔐 Hardened Network Architecture

> Production-simulated secure network infrastructure using Ubuntu VMs, iptables packet filtering, Apache HTTPS, SSH hardening, and a custom Snort IDS engine — built in VMware Workstation.

---

## 📋 Table of Contents

- [Network Topology](#network-topology)
- [VM Overview](#vm-overview)
- [VMware Virtual Network Configuration](#vmware-virtual-network-configuration)
- [Project Phases](#project-phases)
- [Repository Structure](#repository-structure)
- [Quick Start](#quick-start)
- [Verification](#verification)

---

## 🗺️ Network Topology

```
                          ┌─────────────────────────────────┐
  [Kali Attacker]         │         GATEWAY VM              │         [Internal Client]
  200.168.1.100/24  ──── │  ens39: 200.168.1.1/24  (WAN)  │
  (VMnet4)          WAN  │  ens33: 192.168.10.1/24 (LAN)  │ ──── 192.168.10.x/24  (VMnet2)
                         │  ens34: 192.168.20.1/24 (DMZ)  │
                         └────────────┬────────────────────┘
                                      │ DMZ (VMnet3)
                                      │ 192.168.20.0/24
                               ┌──────┴──────┐
                               │  SERVER VM  │
                               │ (pc-b)      │
                               │ 192.168.20.10/24
                               │ Apache HTTP/HTTPS
                               │ SSH (port 22)
                               └─────────────┘
```

---

## 💻 VM Overview

| VM Name | Role | IP Address | Network |
|---|---|---|---|
| `Gateway` | Firewall / Router / IDS | `192.168.10.1` (LAN), `192.168.20.1` (DMZ), `200.168.1.1` (WAN) | VMnet2 + VMnet3 + VMnet4 |
| `pc-b` | Web & SSH Server (DMZ) | `192.168.20.10/24` | VMnet3 |
| `pc-a` | Internal Client | `192.168.10.10/24` | VMnet2 |
| `kali-linux` | Attacker / IDS Evaluation | `200.168.1.100/24` | VMnet4 |

---

## 🔌 VMware Virtual Network Configuration

| VMnet | Type | Subnet | Purpose |
|---|---|---|---|
| VMnet1 | Host-only | 192.168.202.0/24 | VMware default host-only |
| VMnet2 | Host-only | 192.168.10.0/24 | Internal LAN |
| VMnet3 | Host-only | 192.168.20.0/24 | DMZ (Server segment) |
| VMnet4 | Host-only | 200.168.1.0/24 | External / WAN (Attacker segment) |
| VMnet8 | NAT | 192.168.73.0/24 | NAT (internet access) |

---

## 📦 Project Phases

| Phase | Description | Config Location |
|---|---|---|
| **Phase 1** | VM & Network Infrastructure Setup | [`docs/phases/phase1-infrastructure.md`](docs/phases/phase1-infrastructure.md) |
| **Phase 2** | Network Interface Configuration | [`gateway/netplan/`](gateway/netplan/) |
| **Phase 3** | IP Routing & Connectivity | [`docs/phases/phase3-routing.md`](docs/phases/phase3-routing.md) |
| **Phase 4** | Apache HTTPS + SSH Server Setup | [`server/`](server/) |
| **Phase 5** | iptables Firewall (Default-Deny) | [`gateway/iptables/`](gateway/iptables/) |
| **Phase 6** | Snort IDS Installation & Custom Rules | [`gateway/snort/`](gateway/snort/) |

---

## 🗂️ Repository Structure

```
hardened-network-architecture/
├── README.md
├── docs/
│   ├── phases/
│   │   ├── phase1-infrastructure.md
│   │   ├── phase3-routing.md
│   │   └── phase4-services.md
│   └── screenshots/            ← Evidence screenshots
├── gateway/
│   ├── netplan/
│   │   └── 00-gateway.yaml     ← Gateway network interfaces
│   ├── iptables/
│   │   ├── rules.v4            ← Saved iptables ruleset
│   │   └── setup-firewall.sh   ← Firewall provisioning script
│   └── snort/
│       ├── snort.conf          ← Snort IDS configuration
│       └── rules/
│           └── local.rules     ← Custom detection rules
├── server/
│   ├── netplan/
│   │   └── 00-server.yaml      ← Server network config
│   ├── apache/
│   │   ├── 000-default.conf    ← HTTP VirtualHost
│   │   └── default-ssl.conf    ← HTTPS VirtualHost
│   ├── ssl/
│   │   └── gen-cert.sh         ← Self-signed SSL cert generator
│   └── ssh/
│       └── sshd_config         ← Hardened SSH config
├── client/
│   └── netplan/
│       └── 00-client.yaml      ← Client network config
└── scripts/
    ├── setup-gateway.sh        ← Full gateway provisioning
    ├── setup-server.sh         ← Full server provisioning
    └── verify.sh               ← Post-setup verification
```

---

## 🚀 Quick Start

### 1. Clone and review

```bash
git clone https://github.com/YahyaZaghloul/hardened-network-architecture.git
cd hardened-network-architecture
```

### 2. Provision the Gateway VM

```bash
# On the Gateway VM (Ubuntu 24.04)
sudo bash scripts/setup-gateway.sh
```

### 3. Provision the Server VM

```bash
# On pc-b (Ubuntu 24.04)
sudo bash scripts/setup-server.sh
```

### 4. Run Verification

```bash
# From Kali or any external host
bash scripts/verify.sh
```

---

## ✅ Verification

After setup, the following should hold:

- `curl http://192.168.20.10` → Apache default page (via Gateway forward)
- `curl -k https://192.168.20.10` → HTTPS with self-signed cert for `youssef-lab.local`
- `ssh ahmed@192.168.20.10` → SSH access from internal LAN only
- `ping 192.168.20.10` from Kali → **Blocked** (ICMP not forwarded)
- Snort on Gateway → Detects SYN scans, brute-force, ICMP sweeps, etc.

---

## 👥 Authors

Faculty of Computers and Information — Cybersecurity Department  
Network Security Project — 2026

---

## 📄 License

This project is for academic and educational purposes only.
