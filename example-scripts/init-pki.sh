#!/bin/bash

set -euo pipefail

podman run --rm \
  -v /opt/easy-rsa/easy-rsa:/etc/easy-rsa:Z \
  easy-rsa:latest --pki-dir=pki-ca init-pki
