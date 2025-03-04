#!/usr/bin/env bash

# ./create-ct.sh --package-env='{"PROVIDER":"namecheap", "DOMAIN":"proxmoxx79.codeonit.com", "PASSWORD":"efb5e9c74db84dfb8440b699b9496047"}' --package-url=https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/templates/ddns-updater

# curl -s https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/create-ct.sh \
#      | bash -s -- \
#      --hostname=llm \
#      --package-url="https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/templates/llm" \
#      --package-env='{"PROVIDER":"namecheap","DOMAIN":"proxmoxx79.codeonit.com","PASSWORD":"efb5e9c74db84dfb8440b699b9496047"}' \
#      --size=30 \
#      --ssh-public-key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIACmYd5vnc3vUyt5gpj/jKe4MMCnCCrzIqAscv0xO0lG john@Johns-MBP"

# curl -s https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/create-ct.sh \
#      | bash -s -- \
#      --hostname=caddy \
#      --package-url="https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/templates/caddy" \
#      --size=30 \
#      --ssh-public-key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIACmYd5vnc3vUyt5gpj/jKe4MMCnCCrzIqAscv0xO0lG john@Johns-MBP"

# CT_SETUP_DOWNLOAD_FILES='["CaddyFile"]'
# package_url='https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/templates/caddy'
# download_file_array=$(echo "$CT_SETUP_DOWNLOAD_FILES" | jq -r -c '.[]')
# IFS=$'\n'
# for download_file in ${download_file_array[@]}; do
#     echo $download_file
#     # file=$(echo "$download_file" | tr -d '"')
#     # (cd /opt/stacks/default && curl "$package_url/$download_file" --output $download_file)
# done
# unset IFS