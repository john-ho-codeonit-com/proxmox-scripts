#!/usr/bin/env bash

curl -s https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/create-ct.sh \
     | bash -s -- \
     --hostname=dockge \
     --ssh-public-key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIACmYd5vnc3vUyt5gpj/jKe4MMCnCCrzIqAscv0xO0lG john@Johns-MBP"

curl -s https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/create-ct.sh \
     | bash -s -- \
     --hostname=authentik \
     --package-url="https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/templates/authentik" \
     --memory=4096 \
     --size=120 \
     --ssh-public-key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIACmYd5vnc3vUyt5gpj/jKe4MMCnCCrzIqAscv0xO0lG john@Johns-MBP" \
     --package-env='{"PG_PASS":"zECfDucu9dGi5mtYQwb71lZpxji0hWQtERtMjpQjItCBrmh6","AUTHENTIK_SECRET_KEY":"1kprlKgUGSBPDh1INQBc5k8wpDuReQlQJ3V5hz79A5MjKNCUM/zOZZx9HzH8T7dBfqZy2KdlFFcGDSwA","AUTHENTIK_ERROR_REPORTING__ENABLED":true}'

curl -s https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/create-ct.sh \
     | bash -s -- \
     --hostname=caddy \
     --package-url="https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/templates/caddy" \
     --size=16 \
     --memory=4096 \
     --ssh-public-key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIACmYd5vnc3vUyt5gpj/jKe4MMCnCCrzIqAscv0xO0lG john@Johns-MBP" \
     --package-env='{"NAMECHEAP_API_KEY":"NAMECHEAP_API_KEY","NAMECHEAP_USER":"NAMECHEAP_USER","DOCKGE_URL":"dockge:5001","AUTHENTIK_URL":"authentik:9000","DDNSUPDATER_URL":"ddnsupdater:8000","OPENWEBUI_URL":"openwebui:3000"}'

curl -s https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/create-ct.sh \
     | bash -s -- \
     --hostname=ddnsupdater \
     --package-url="https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/templates/ddnsupdater" \
     --ssh-public-key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIACmYd5vnc3vUyt5gpj/jKe4MMCnCCrzIqAscv0xO0lG john@Johns-MBP" \
     --package-env='{"CT_SETUP_CONFIG":{"settings":[{"provider":"namecheap","domain":"codeonit.com","password":"efb5e9c74db84dfb8440b699b9496047"},{"provider":"namecheap","domain":"apps.codeonit.com","password":"efb5e9c74db84dfb8440b699b9496047"},{"provider":"namecheap","domain":"dockge.codeonit.com","password":"efb5e9c74db84dfb8440b699b9496047"},{"provider":"namecheap","domain":"ddnsupdater.codeonit.com","password":"efb5e9c74db84dfb8440b699b9496047"},{"provider":"namecheap","domain":"openwebui.codeonit.com","password":"efb5e9c74db84dfb8440b699b9496047"},{"provider":"namecheap","domain":"code.codeonit.com","password":"efb5e9c74db84dfb8440b699b9496047"}]}}'

curl -s https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/create-ct.sh \
     | bash -s -- \
     --hostname=openwebui \
     --package-url="https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/templates/openwebui" \
     --memory=16000 \
     --size=120 \
     --ssh-public-key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIACmYd5vnc3vUyt5gpj/jKe4MMCnCCrzIqAscv0xO0lG john@Johns-MBP"

curl -s https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/create-ct.sh \
     | bash -s -- \
     --hostname=codeserver \
     --package-url="https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/templates/codeserver" \
     --memory=16000 \
     --size=120 \
     --ssh-public-key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIACmYd5vnc3vUyt5gpj/jKe4MMCnCCrzIqAscv0xO0lG john@Johns-MBP"
