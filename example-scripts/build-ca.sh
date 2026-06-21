#!/bin/bash
# Usage: ./build-ca.sh <pki-dir> <crl-uri> <ocsp-uri> <req-cn>
# Example (root):         ./build-ca.sh pki-ca http://crl.example.com/ca.crl http://ocsp.example.com "Root CA"
# Example (intermediate): ./build-ca.sh pki-int-vpn http://crl.example.com/vpn.crl http://ocsp.example.com "VPN CA"

set -euo pipefail

MIKROTIK_HOST="192.168.1.1"
MIKROTIK_USER="admin"
MIKROTIK_PATH="/ca/"

PKI_DIR=${1:?Usage: $0 <pki-dir> <crl-uri> <ocsp-uri> <req-cn>}
CRL_URI=${2:?Usage: $0 <pki-dir> <crl-uri> <ocsp-uri> <req-cn>}
OCSP_URI=${3:?Usage: $0 <pki-dir> <crl-uri> <ocsp-uri> <req-cn>}
REQ_CN=${4:?Usage: $0 <pki-dir> <crl-uri> <ocsp-uri> <req-cn>}

if [[ "$PKI_DIR" == pki-int-* ]]; then
    BUILD_CMD="build-ca subca"
else
    BUILD_CMD="build-ca"
fi

podman run --rm -it \
  -v /opt/easy-rsa/easy-rsa:/etc/easy-rsa:Z \
  -e EASYRSA_CRL_URI="$CRL_URI" \
  -e EASYRSA_OCSP_URI="$OCSP_URI" \
  easy-rsa:latest --pki-dir="$PKI_DIR" --req-cn="$REQ_CN" $BUILD_CMD

scp /opt/easy-rsa/easy-rsa/"$PKI_DIR"/ca.crt \
  "$MIKROTIK_USER@$MIKROTIK_HOST:$MIKROTIK_PATH"
