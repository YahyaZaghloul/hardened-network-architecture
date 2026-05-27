# Phase 3 — IP Addressing & Routing

## IP Address Scheme

| VM | Interface | IP Address | Subnet | Gateway | Network |
|---|---|---|---|---|---|
| Gateway | ens33 (enp2s1) | 192.168.10.1 | /24 | — | Internal LAN (VMnet2) |
| Gateway | ens34 (enp2s2) | 192.168.20.1 | /24 | — | DMZ (VMnet3) |
| Gateway | ens39 (enp2s7) | 200.168.1.1 | /24 | — | External WAN (VMnet4) |
| pc-b (Server) | ens33 | 192.168.20.10 | /24 | 192.168.20.1 | DMZ (VMnet3) |
| pc-a (Client) | ens33 | 192.168.10.10 | /24 | 192.168.10.1 | Internal LAN (VMnet2) |
| Kali (Attacker) | eth1 | 200.168.1.100 | /24 | 200.168.1.1 | External WAN (VMnet4) |

---

## Gateway Configuration

### Apply Netplan
```bash
sudo cp gateway/netplan/00-gateway.yaml /etc/netplan/
sudo netplan apply
ip a   # verify all 3 interfaces have correct IPs
```

### Enable IP Forwarding
```bash
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
# Make permanent:
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sudo sysctl -p
```

### Verify Gateway Routing Table
```
default via 200.168.1.1 dev ens39
192.168.10.0/24 dev ens33 proto kernel scope link
192.168.20.0/24 dev ens34 proto kernel scope link
200.168.1.0/24  dev ens39 proto kernel scope link
```

---

## Server (pc-b) Configuration

### Apply Netplan
```bash
sudo cp server/netplan/00-server.yaml /etc/netplan/
sudo netplan apply
ip a        # ens33 should show 192.168.20.10/24
ip route    # default via 192.168.20.1
```

### Verify Server Routing Table
```
default via 192.168.20.1 dev ens33 proto static metric 20100
192.168.20.0/24 dev ens33 proto kernel scope link src 192.168.20.10 metric 100
```

---

## Client (pc-a) Configuration

### Apply Netplan
```bash
sudo cp client/netplan/00-client.yaml /etc/netplan/
sudo netplan apply
ip a        # ens33 should show 192.168.10.10/24
ip route    # default via 192.168.10.1
```

---

## Kali (Attacker) Configuration

Kali uses `eth1` connected to VMnet4:
```bash
ip addr add 200.168.1.100/24 dev eth1
ip route add default via 200.168.1.1 dev eth1
```

Or via `/etc/network/interfaces`:
```
auto eth1
iface eth1 inet static
    address 200.168.1.100
    netmask 255.255.255.0
    gateway 200.168.1.1
```

---

## Connectivity Verification

```bash
# From Kali — ping Gateway WAN
ping 200.168.1.1

# From Kali — access server HTTP (via Gateway forward)
curl http://192.168.20.10

# From pc-a (Client) — SSH to server
ssh ahmed@192.168.20.10

# From Kali — confirm ICMP to server is BLOCKED
ping 192.168.20.10    # Should time out (no ICMP forward rule)
```
