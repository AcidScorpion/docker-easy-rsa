#!/bin/bash
# Usage: ./issue-cert.sh <pki-dir> <type> <name> <req-cn> [san]
# Example server: ./issue-cert.sh pki-int-vpn server vpn-gw "VPN Gateway" "DNS:vpn.example.com,IP:10.0.0.1"
# Example client: ./issue-cert.sh pki-int-vpn client john "John Doe"

set -euo pipefail

MIKROTIK_HOST="192.168.1.1"
MIKROTIK_USER="admin"
MIKROTIK_PATH="/cert/"

PKI_DIR=${1:?Usage: $0 <pki-dir> <type> <name> <req-cn> [san]}
CERT_TYPE=${2:?Usage: $0 <pki-dir> <type> <name> <req-cn> [san]}
NAME=${3:?Usage: $0 <pki-dir> <type> <name> <req-cn> [san]}
REQ_CN=${4:?Usage: $0 <pki-dir> <type> <name> <req-cn> [san]}
SAN=${5:-}

BASE_PATH="/opt/easy-rsa/easy-rsa/$PKI_DIR"

if [[ "$CERT_TYPE" == "server" ]]; then
    DAYS=730
else
    DAYS=365
fi

GEN_ARGS=(--rm -it -v /opt/easy-rsa/easy-rsa:/etc/easy-rsa:Z)
[[ -n "$SAN" ]] && GEN_ARGS+=(-e EASYRSA_REQ_SAN="$SAN")

podman run "${GEN_ARGS[@]}" \
  easy-rsa:latest --pki-dir="$PKI_DIR" --req-cn="$REQ_CN" gen-req "$NAME" nopass

podman run --rm -it \
  -v /opt/easy-rsa/easy-rsa:/etc/easy-rsa:Z \
  easy-rsa:latest --pki-dir="$PKI_DIR" --days="$DAYS" sign-req "$CERT_TYPE" "$NAME"

P12_PASS=$(openssl rand -base64 20 | tr -d '=+/\n' | head -c 20)

mkdir -p "$BASE_PATH/exported"
openssl pkcs12 -export \
  -in "$BASE_PATH/issued/$NAME.crt" \
  -inkey "$BASE_PATH/private/$NAME.key" \
  -certfile "$BASE_PATH/ca.crt" \
  -out "$BASE_PATH/exported/$NAME.p12" \
  -passout "pass:$P12_PASS"

scp "$BASE_PATH/exported/$NAME.p12" \
  "$MIKROTIK_USER@$MIKROTIK_HOST:$MIKROTIK_PATH"

echo ""
echo "P12 password for $NAME: $P12_PASS"
