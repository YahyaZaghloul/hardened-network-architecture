#!/usr/bin/env bash
# =============================================================================
# gen-cert.sh — Self-Signed SSL Certificate Generator
# =============================================================================
# Certificate Details (as verified in browser):
#   Domain:       youssef-lab.local
#   Country:      EG
#   State:        Giza
#   Locality:     Giza
#   Organization: Faculty of Computers and Information
#   Org Unit:     Cybersecurity
#   Common Name:  youssef-lab.local
#   Email:        admin@youssef-lab.local
#   Validity:     365 days (1 year)
#   Key:          RSA 2048-bit
#   Signature:    SHA-256 with RSA Encryption
# =============================================================================

set -e

DOMAIN="youssef-lab.local"
CERT_DIR="/etc/ssl/certs"
KEY_DIR="/etc/ssl/private"
CERT_FILE="$CERT_DIR/$DOMAIN.crt"
KEY_FILE="$KEY_DIR/$DOMAIN.key"
CSR_FILE="/tmp/$DOMAIN.csr"

echo "[*] Generating RSA 2048-bit private key..."
openssl genrsa -out "$KEY_FILE" 2048
chmod 600 "$KEY_FILE"

echo "[*] Generating Certificate Signing Request (CSR)..."
openssl req -new \
  -key "$KEY_FILE" \
  -out "$CSR_FILE" \
  -subj "/C=EG/ST=Giza/L=Giza/O=Faculty of Computers and Information/OU=Cybersecurity/CN=$DOMAIN/emailAddress=admin@$DOMAIN"

echo "[*] Generating self-signed certificate (365 days, SHA-256)..."
openssl x509 -req \
  -days 365 \
  -in "$CSR_FILE" \
  -signkey "$KEY_FILE" \
  -out "$CERT_FILE" \
  -sha256 \
  -extensions v3_req \
  -extfile <(cat <<EOF
[v3_req]
subjectAltName = DNS:$DOMAIN, DNS:www.$DOMAIN, IP:192.168.20.10
basicConstraints = CA:TRUE
EOF
)

echo "[*] Cleaning up CSR..."
rm -f "$CSR_FILE"

echo ""
echo "[+] Certificate generated:"
echo "    Cert: $CERT_FILE"
echo "    Key:  $KEY_FILE"
echo ""
echo "[*] Certificate details:"
openssl x509 -in "$CERT_FILE" -text -noout | grep -E "Subject:|Issuer:|Not Before|Not After|Public-Key:"

echo ""
echo "[*] Enabling Apache SSL module and site..."
a2enmod ssl headers
a2ensite default-ssl
systemctl reload apache2

echo "[+] Done. Access via: https://$DOMAIN  or  https://192.168.20.10"
