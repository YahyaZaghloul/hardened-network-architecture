# Phase 1 — Infrastructure Setup

## Objective
Deploy four Ubuntu/Kali VMs in VMware Workstation and configure the virtual network switches to simulate a real enterprise network topology.

---

## VMware Virtual Network Editor Settings

Open **Edit → Virtual Network Editor** in VMware Workstation and configure:

| VMnet | Type | Subnet | DHCP | Purpose |
|---|---|---|---|---|
| VMnet2 | Host-only | 192.168.10.0/24 | Off | Internal LAN |
| VMnet3 | Host-only | 192.168.20.0/24 | Off | DMZ |
| VMnet4 | Host-only | 200.168.1.0/24 | Off | External WAN |

---

## VM Specifications & Network Adapter Assignments

### Gateway VM
| Resource | Value |
|---|---|
| OS | Ubuntu 24.04 LTS |
| RAM | 2 GB |
| CPU | 2 vCPUs |
| Disk | 20 GB |
| Network Adapter 1 | Custom: VMnet2 (Internal LAN) |
| Network Adapter 2 | Custom: VMnet3 (DMZ) |
| Network Adapter 3 | Custom: VMnet4 (External WAN) |

### pc-b — Server VM (DMZ)
| Resource | Value |
|---|---|
| OS | Ubuntu 24.04 LTS |
| RAM | 2 GB |
| CPU | 2 vCPUs |
| Disk | 20 GB |
| Network Adapter 1 | Custom: VMnet3 (DMZ) |

### pc-a — Internal Client VM
| Resource | Value |
|---|---|
| OS | Ubuntu 24.04 LTS |
| RAM | 2 GB |
| CPU | 2 vCPUs |
| Disk | 20 GB |
| Network Adapter 1 | Custom: VMnet2 (Internal LAN) |

### kali-linux — Attacker VM
| Resource | Value |
|---|---|
| OS | Kali Linux 2026.1 (amd64) |
| RAM | 2 GB |
| CPU | 4 vCPUs |
| Disk | 80.1 GB |
| Network Adapter 1 | Custom: VMnet4 (External WAN) |

---

## Installation Steps

1. Download Ubuntu 24.04 LTS ISO and Kali Linux ISO
2. Create each VM in VMware using the specs above
3. Install Ubuntu/Kali on each VM
4. Assign the correct VMnet adapter to each VM via **VM → Settings → Network Adapter**
5. Verify each VM boots and has a working shell

---

## Expected Result

All 4 VMs appear in VMware Workstation as **Powered On** under the `project_final` library group.
