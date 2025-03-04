#!/usr/bin/env bash

# ./create-ct.sh --package-env='{"PROVIDER":"namecheap", "DOMAIN":"proxmoxx79.codeonit.com", "PASSWORD":"efb5e9c74db84dfb8440b699b9496047"}' --package-url=https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/templates/ddns-updater

# curl -s https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/create-ct.sh \
#      | bash -s -- \
#      --hostname=llm \
#      --package-url="https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/templates/llm" \
#      --package-env='{"PROVIDER":"namecheap","DOMAIN":"proxmoxx79.codeonit.com","PASSWORD":"efb5e9c74db84dfb8440b699b9496047"}' \
#      --size=30 \
#      --ssh-public-key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIACmYd5vnc3vUyt5gpj/jKe4MMCnCCrzIqAscv0xO0lG john@Johns-MBP"


# package_env='{"a:"namecheap","d":"proxmoxx79.codeonit.com","p":"efb5e9c74db84dfb8440b699b9496047"}'
# if ! jq -e . >/dev/null 2>&1 <<<"$package_env"; then
#     echo "Failed to parse JSON, or got false/null"
# fi


# json_val=$(jq -re '""' <<<"$package_env")
# echo $json_val
# if [ "${json_val}" ]; then
#     echo "package-env json string is invalid"
# fi

DOWNLOAD_FILES='["a", "b"]'
files=$(echo "$DOWNLOAD_FILES" | jq -c '.[]')
IFS=$'\n'
for file in ${files[@]}; do
    echo $file
done
unset IFS