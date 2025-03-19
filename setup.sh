#!/usr/bin/env bash

curl -s https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/create-ct.sh \
     | bash -s -- \
     --hostname=dockge \
     --mac="90:2B:34:56:10:1F" \
     --ssh-public-key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIACmYd5vnc3vUyt5gpj/jKe4MMCnCCrzIqAscv0xO0lG john@Johns-MBP"

curl -s https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/create-ct.sh \
     | bash -s -- \
     --hostname=caddy \
     --package-url="https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/templates/caddy" \
     --size=16 \
     --mac="90:2B:34:56:10:2F" \
     --memory=4096 \
     --ssh-public-key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIACmYd5vnc3vUyt5gpj/jKe4MMCnCCrzIqAscv0xO0lG john@Johns-MBP" \
     --package-env='{"NAMECHEAP_API_KEY":"NAMECHEAP_API_KEY","NAMECHEAP_USER":"NAMECHEAP_USER","DOCKGE_URL":"192.168.50.185:5001","AUTHENTIK_URL":"192.168.50.46:9000","DDNSUPDATER_URL":"192.168.50.198:8000","OPENWEBUI_URL":"192.168.50.128:3000",CODESERVER_URL":"192.168.50.109:8443"}'

curl -s https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/create-ct.sh \
     | bash -s -- \
     --hostname=authentik \
     --package-url="https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/templates/authentik" \
     --memory=4096 \
     --size=120 \
     --mac="90:2B:34:56:10:3F" \
     --ssh-public-key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIACmYd5vnc3vUyt5gpj/jKe4MMCnCCrzIqAscv0xO0lG john@Johns-MBP" \
     --package-env='{"PG_PASS":"zECfDucu9dGi5mtYQwb71lZpxji0hWQtERtMjpQjItCBrmh6","AUTHENTIK_SECRET_KEY":"1kprlKgUGSBPDh1INQBc5k8wpDuReQlQJ3V5hz79A5MjKNCUM/zOZZx9HzH8T7dBfqZy2KdlFFcGDSwA","AUTHENTIK_ERROR_REPORTING__ENABLED":true}'

curl -s https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/create-ct.sh \
     | bash -s -- \
     --hostname=ddnsupdater \
     --mac="90:2B:34:56:10:4F" \
     --package-url="https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/templates/ddnsupdater" \
     --ssh-public-key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIACmYd5vnc3vUyt5gpj/jKe4MMCnCCrzIqAscv0xO0lG john@Johns-MBP" \
     --package-env='{"CT_SETUP_CONFIG":{"settings":[{"provider":"namecheap","domain":"codeonit.com","password":"efb5e9c74db84dfb8440b699b9496047"},{"provider":"namecheap","domain":"apps.codeonit.com","password":"efb5e9c74db84dfb8440b699b9496047"},{"provider":"namecheap","domain":"dockge.codeonit.com","password":"efb5e9c74db84dfb8440b699b9496047"},{"provider":"namecheap","domain":"ddnsupdater.codeonit.com","password":"efb5e9c74db84dfb8440b699b9496047"},{"provider":"namecheap","domain":"openwebui.codeonit.com","password":"efb5e9c74db84dfb8440b699b9496047"},{"provider":"namecheap","domain":"codeserver.codeonit.com","password":"efb5e9c74db84dfb8440b699b9496047"}]}}'

curl -s https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/create-ct.sh \
     | bash -s -- \
     --hostname=openwebui \
     --mac="90:2B:34:56:10:5F" \
     --package-url="https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/templates/openwebui" \
     --memory=16000 \
     --size=220 \
     --ssh-public-key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIACmYd5vnc3vUyt5gpj/jKe4MMCnCCrzIqAscv0xO0lG john@Johns-MBP"

curl -s https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/create-ct.sh \
     | bash -s -- \
     --hostname=codeserver \
     --mac="90:2B:34:56:10:6F" \
     --package-url="https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/templates/codeserver" \
     --memory=16000 \
     --size=120 \
     --ssh-public-key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIACmYd5vnc3vUyt5gpj/jKe4MMCnCCrzIqAscv0xO0lG john@Johns-MBP"

curl -s https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/create-ct.sh \
     | bash -s -- \
     --hostname=openmanus \
     --mac="90:2B:34:56:10:7F" \
     --package-url="https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/templates/openmanus" \
     --memory=8192 \
     --size=120 \
     --ssh-public-key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIACmYd5vnc3vUyt5gpj/jKe4MMCnCCrzIqAscv0xO0lG john@Johns-MBP"

curl -s https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/create-ct.sh \
     | bash -s -- \
     --hostname=n8n \
     --mac="90:2B:34:56:10:8F" \
     --package-url="https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/templates/n8n" \
     --memory=8192 \
     --size=120 \
     --ssh-public-key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIACmYd5vnc3vUyt5gpj/jKe4MMCnCCrzIqAscv0xO0lG john@Johns-MBP"
