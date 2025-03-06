#!/usr/bin/env bash

# ./create-ct.sh --package-env='{"PROVIDER":"namecheap", "DOMAIN":"proxmoxx79.codeonit.com", "PASSWORD":"efb5e9c74db84dfb8440b699b9496047"}' --package-url=https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/templates/ddns-updater

# curl -s https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/create-ct.sh \
#      | bash -s -- \
#      --hostname=prompt \
#      --package-url="https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/templates/prompt" \
#      --memory=16000
#      --size=120 \
#      --ssh-public-key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIACmYd5vnc3vUyt5gpj/jKe4MMCnCCrzIqAscv0xO0lG john@Johns-MBP"

# curl -s https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/create-ct.sh \
#      | bash -s -- \
#      --hostname=caddy \
#      --package-url="https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/templates/caddy" \
#      --size=16 \
#      --ssh-public-key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIACmYd5vnc3vUyt5gpj/jKe4MMCnCCrzIqAscv0xO0lG john@Johns-MBP"

curl -s https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/create-ct.sh \
     | bash -s -- \
     --hostname=authentik \
     --package-url="https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/templates/authentik" \
     --size=120 \
     --ssh-public-key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIACmYd5vnc3vUyt5gpj/jKe4MMCnCCrzIqAscv0xO0lG john@Johns-MBP" \
     --package-env='{"PG_PASS":"zECfDucu9dGi5mtYQwb71lZpxji0hWQtERtMjpQjItCBrmh6","AUTHENTIK_SECRET_KEY":"1kprlKgUGSBPDh1INQBc5k8wpDuReQlQJ3V5hz79A5MjKNCUM/zOZZx9HzH8T7dBfqZy2KdlFFcGDSwA","AUTHENTIK_ERROR_REPORTING__ENABLED":true}' \
