# =============================================================================
# Wireless Security Configuration
# Device: Etisalat ZTE Router (192.168.1.99)
# =============================================================================

## Overview

This section documents the wireless router security hardening performed as
part of the Network Security project. The router used is an **Etisalat ZTE**
home router accessed via its web admin interface at `http://192.168.1.99`.

---

## Router Admin Access

| Field | Value |
|---|---|
| Admin URL | `http://192.168.1.99` |
| Username | `user` |
| Default password | Changed (see below) |

---

## Security Steps Applied

### 1. Change Default Admin Password

Navigate to: **Administration → User Management**

- Username: `user`
- Old Password: *(factory default)*
- New Password: Strong password (7+ characters, mixed case)
- Confirmed Password: *(same as new password)*

> **Why:** Default router credentials are publicly known and are the #1 attack vector for home/SOHO routers.

---

### 2. WPA2-PSK Wireless Encryption

Navigate to: **Network → Wireless → Security**

| Setting | Value |
|---|---|
| Security Mode | WPA2-PSK (AES) |
| Encryption | AES (CCMP) |
| Pre-Shared Key | Strong passphrase (12+ characters) |
| WPS | **Disabled** |

> **Why:** WPA2-PSK with AES is the minimum recommended standard. WPA (TKIP) is deprecated and vulnerable to TKIP attacks.

---

### 3. SSID Configuration

Navigate to: **Network → Wireless → Basic**

| Setting | Value |
|---|---|
| SSID Broadcast | **Disabled** (Hidden SSID) |
| SSID Name | Custom (non-identifying) |
| Channel | Fixed channel (e.g., 6 or 11) to avoid auto-interference |

> **Why:** Hiding the SSID adds a layer of obscurity. Clients must know the SSID name to connect.

---

### 4. MAC Address Filtering

Navigate to: **Security → MAC Filter**

| Setting | Value |
|---|---|
| MAC Filtering | **Enabled** |
| Mode | Allow listed MACs only (whitelist) |

Only authorized device MAC addresses are added to the allow list.

> **Why:** Even if the WPA2 key is compromised, unlisted devices cannot associate with the AP.

---

### 5. Disable WPS (Wi-Fi Protected Setup)

Navigate to: **Network → Wireless → WPS**

| Setting | Value |
|---|---|
| WPS Status | **Disabled** |

> **Why:** WPS PIN is vulnerable to brute-force attacks (Reaver/Bully tools). Disabling it removes this attack surface entirely.

---

### 6. Firewall & Remote Management

Navigate to: **Security → Firewall**

| Setting | Value |
|---|---|
| Firewall | **Enabled** |
| Remote Management | **Disabled** |
| UPnP | **Disabled** |

---

## Security Checklist

- [x] Default admin password changed
- [x] WPA2-PSK (AES) encryption enabled
- [x] WPS disabled
- [x] SSID hidden (broadcast disabled)
- [x] MAC address filtering enabled (whitelist mode)
- [x] Router firewall enabled
- [x] Remote management disabled
- [x] UPnP disabled
