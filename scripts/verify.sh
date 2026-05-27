#!/usr/bin/env bash
# =============================================================================
# verify.sh — Post-Setup Verification Script
# Run from Kali (200.168.1.100) or internal client (192.168.10.10)
# =============================================================================

SERVER_IP="192.168.20.10"
GATEWAY_WAN="200.168.1.1"
PASS=0
FAIL=0

ok()   { echo "  [PASS] $1"; ((PASS++)); }
fail() { echo "  [FAIL] $1"; ((FAIL++)); }
info() { echo ""; echo "=== $1 ==="; }

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║     Hardened Network Architecture — Verification     ║"
echo "╚══════════════════════════════════════════════════════╝"

# -----------------------------------------------------------------------
info "1. Gateway Reachability"
# -----------------------------------------------------------------------
if ping -c 2 -W 2 $GATEWAY_WAN &>/dev/null; then
    ok "Gateway WAN ($GATEWAY_WAN) is reachable"
else
    fail "Gateway WAN ($GATEWAY_WAN) not reachable"
fi

# -----------------------------------------------------------------------
info "2. HTTP Access to Server (port 80)"
# -----------------------------------------------------------------------
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://$SERVER_IP || echo "000")
if [[ "$HTTP_CODE" == "200" || "$HTTP_CODE" == "301" || "$HTTP_CODE" == "302" ]]; then
    ok "HTTP port 80 → response $HTTP_CODE (accessible)"
else
    fail "HTTP port 80 → response $HTTP_CODE (blocked or down)"
fi

# -----------------------------------------------------------------------
info "3. HTTPS Access to Server (port 443)"
# -----------------------------------------------------------------------
HTTPS_CODE=$(curl -sk -o /dev/null -w "%{http_code}" --max-time 5 https://$SERVER_IP || echo "000")
if [[ "$HTTPS_CODE" == "200" ]]; then
    ok "HTTPS port 443 → response $HTTPS_CODE (accessible)"
else
    fail "HTTPS port 443 → response $HTTPS_CODE (blocked or cert error)"
fi

# Check SSL cert CN
SSL_CN=$(echo | openssl s_client -connect $SERVER_IP:443 2>/dev/null | openssl x509 -noout -subject 2>/dev/null | grep -o "CN=.*" || echo "N/A")
if echo "$SSL_CN" | grep -q "youssef-lab.local"; then
    ok "SSL certificate CN: $SSL_CN"
else
    fail "SSL certificate CN unexpected: $SSL_CN"
fi

# -----------------------------------------------------------------------
info "4. SSH Access to Server (port 22)"
# -----------------------------------------------------------------------
SSH_BANNER=$(timeout 5 bash -c "echo '' | nc -w3 $SERVER_IP 22 2>/dev/null" || echo "")
if echo "$SSH_BANNER" | grep -qi "ssh\|openssh"; then
    ok "SSH port 22 is open and responding"
else
    fail "SSH port 22 is blocked or not responding"
fi

# -----------------------------------------------------------------------
info "5. ICMP (Ping) to Server — Should Be BLOCKED by Firewall"
# -----------------------------------------------------------------------
if ping -c 2 -W 2 $SERVER_IP &>/dev/null; then
    fail "ICMP to server is ALLOWED (should be blocked by Gateway)"
else
    ok "ICMP to server is BLOCKED (firewall working correctly)"
fi

# -----------------------------------------------------------------------
info "6. Blocked Port Test — Port 8080 should be DROPPED"
# -----------------------------------------------------------------------
PORT_TEST=$(timeout 3 bash -c "echo '' | nc -w2 $SERVER_IP 8080 2>&1" || echo "timeout")
if echo "$PORT_TEST" | grep -qi "timeout\|refused\|timed out"; then
    ok "Port 8080 is BLOCKED (default-deny working)"
else
    fail "Port 8080 is OPEN (firewall misconfiguration)"
fi

# -----------------------------------------------------------------------
info "7. Snort IDS — Trigger Detection (ICMP Sweep)"
# -----------------------------------------------------------------------
echo "  [INFO] Sending 10 pings to trigger ICMP Sweep rule on Gateway..."
ping -c 10 $SERVER_IP &>/dev/null || true
echo "  [INFO] Check Gateway: sudo tail -20 /var/log/snort/alert"
echo "  [INFO] Expected:  [1:1000003:1] ICMP Ping Sweep Detected"

# -----------------------------------------------------------------------
info "Summary"
# -----------------------------------------------------------------------
TOTAL=$((PASS + FAIL))
echo ""
echo "  Results: $PASS/$TOTAL checks passed"
if [[ $FAIL -eq 0 ]]; then
    echo "  ✅ All checks passed — network is correctly hardened!"
else
    echo "  ⚠️  $FAIL check(s) failed — review configuration."
fi
echo ""
