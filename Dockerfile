FROM alpine:latest

RUN apk update && apk add --no-cache easy-rsa && \
    mkdir -p /etc/easy-rsa && \
    chmod 0750 /etc/easy-rsa

WORKDIR /etc/easy-rsa

# Declare mount point — bind with :Z on SELinux (RHEL10/Podman)
VOLUME ["/etc/easy-rsa"]

ENTRYPOINT ["/usr/share/easy-rsa/easyrsa"]
