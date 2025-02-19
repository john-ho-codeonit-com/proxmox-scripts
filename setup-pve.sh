#!/usr/bin/env bash

curl -s "https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/setup-ct.sh" \
     | ssh root@$hostname bash -s -- $setup_ct_args