#!/bin/bash
# Usage: ./revoke-cert.sh <pki-dir> <name>
# Example: ./revoke-cert.sh pki-int-vpn john

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

PKI_DIR=${1:?Usage: $0 <pki-dir> <name>}
NAME=${2:?Usage: $0 <pki-dir> <name>}

podman run --rm -it \
  -v /opt/easy-rsa/easy-rsa:/etc/easy-rsa:Z \
  easy-rsa:latest --pki-dir="$PKI_DIR" revoke "$NAME"

"$SCRIPT_DIR/gen-crl.sh" "$PKI_DIR"
