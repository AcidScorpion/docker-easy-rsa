#!/bin/bash

set -euo pipefail

MIKROTIK_HOST="192.168.1.1"
MIKROTIK_USER="admin"
MIKROTIK_PATH="/cert/"

PKI_DIR=${1:?Usage: $0 <pki-dir>}

podman run --rm \
  -v /opt/easy-rsa/easy-rsa:/etc/easy-rsa:Z \
  easy-rsa:latest --pki-dir="$PKI_DIR" gen-crl

scp /opt/easy-rsa/easy-rsa/"$PKI_DIR"/crl.pem \
  "$MIKROTIK_USER@$MIKROTIK_HOST:$MIKROTIK_PATH"
