#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERTS_DIR="$SCRIPT_DIR/../../certs"

NODES=("fog3-a" "fog3-b" "fog3-c")
for NODE in "${NODES[@]}"
do
  mkdir -p "$CERTS_DIR/bolt/$NODE"
  openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout "$CERTS_DIR/bolt/$NODE/private.key" \
    -out "$CERTS_DIR/bolt/$NODE/public.crt" \
    -subj "//CN=$NODE" \
    -addext "subjectAltName=DNS:$NODE,DNS:localhost,IP:127.0.0.1"
done
echo "Certificados generados correctamente."