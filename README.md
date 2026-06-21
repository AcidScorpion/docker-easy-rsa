# Manage certificates with easy-rsa

## Make image

```text
podman build -t easy-rsa:latest .
```

Or, with version:

```text
podman build -t easy-rsa:1.0.0 -t lisamaht:latest
```

## SELinux

On RHEL10 with Podman and SELinux enforcing, add the `:Z` suffix to the volume mount, otherwise the process inside the container will get `Permission denied`:

```text
podman run --rm \
  -v /path/to/easy-rsa:/etc/easy-rsa:Z \
  easy-rsa:latest init-pki
```

**`:Z`** — private label (`svirt_sandbox_file_t`): the host directory is accessible only to this container.  
**`:z`** — shared label: the host directory can be accessed by multiple containers simultaneously.

> **Warning:** `:Z` will relabel the SELinux context of the host directory. Do not use it on system directories (e.g. `$HOME` itself).

## Scripts

All scripts are run on the host over SSH. The data directory `/opt/easy-rsa/easy-rsa` is created by Ansible.

| Script | Description |
| --- | --- |
| `init-pki.sh` | Initialize PKI structure |
| `build-ca.sh` | Build CA, prompts for password interactively, uploads CA cert to Mikrotik |
| `gen-crl.sh` | Generate CRL and upload to Mikrotik via scp |
| `issue-cert.sh` | Generate, sign, export PKCS12 and upload to Mikrotik |
| `revoke-cert.sh` | Revoke a certificate and update CRL on Mikrotik |

### init-pki.sh

```text
./example-scripts/init-pki.sh
```

### build-ca.sh

```text
./example-scripts/build-ca.sh <pki-dir> <crl-uri> <ocsp-uri> <req-cn>
```

Automatically uses `build-ca subca` for intermediate CAs when `pki-dir` starts with `pki-int-`. Uploads `ca.crt` to Mikrotik at `/ca/` after build.

### gen-crl.sh

```text
./example-scripts/gen-crl.sh <pki-dir>
```

Use `pki-ca` for root CA or the intermediate PKI directory name.

### issue-cert.sh

```text
./example-scripts/issue-cert.sh <pki-dir> <type> <name> <req-cn> [san]
```

`type`: `server` or `client`. Server certs get 730 days, client certs 365 days.  
`san`: optional, required for server certs. Format: `DNS:example.com,IP:10.0.0.1`

Generates the key and CSR, signs with CA (prompts for CA password), exports PKCS12 with a random password, uploads to Mikrotik, and prints the PKCS12 password.

```text
./example-scripts/issue-cert.sh pki-int-vpn server vpn-gw "VPN Gateway" "DNS:vpn.example.com,IP:10.0.0.1"
./example-scripts/issue-cert.sh pki-int-vpn client john "John Doe"
```

### revoke-cert.sh

```text
./example-scripts/revoke-cert.sh <pki-dir> <name>
```

Revokes the certificate, regenerates CRL and uploads it to Mikrotik.

```text
./example-scripts/revoke-cert.sh pki-int-vpn john
```
