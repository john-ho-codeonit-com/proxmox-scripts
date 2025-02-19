#!/usr/bin/env bash
hostname=x79pve

ssh-keygen -f ~/.ssh/known_hosts -R $hostname
ssh_public_key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMdIkri7L7jgb6jAf+FrcxiE59OrxuHTw7TvWnt/jGBw john@Johns-MBP"
echo "$ssh_public_key" | sshpass -p 'Kazsuma1' ssh root@$hostname -oStrictHostKeyChecking=accept-new 'cat >> /root/.ssh/authorized_keys'
sshpass -p 'Kazsuma1' ssh root@$hostname "cat /root/.ssh/authorized_keys"

ssh -t root@x79pve 'bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/misc/post-pve-install.sh)"'
sleep 20
until [ $(ssh-keyscan $hostname >/dev/null 2>&1)$? -eq 0 ]; do echo "waiting for reboot to complete..."; sleep 1; done

curl -s "https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/setup-ct.sh" \
     | ssh root@$hostname bash -s

echo run other stuff
