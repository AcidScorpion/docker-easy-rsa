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
