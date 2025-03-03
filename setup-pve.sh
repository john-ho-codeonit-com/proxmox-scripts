#!/usr/bin/env bash
# TODO:  make command line

hostname=x79pve

echo "Setting up ssh key"
ssh-keygen -f ~/.ssh/known_hosts -R $hostname
ssh_public_key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMdIkri7L7jgb6jAf+FrcxiE59OrxuHTw7TvWnt/jGBw john@Johns-MBP"
echo "$ssh_public_key" | sshpass -p 'Kazsuma1' ssh root@$hostname -oStrictHostKeyChecking=accept-new 'cat >> /root/.ssh/authorized_keys'
sshpass -p 'Kazsuma1' ssh root@$hostname "cat /root/.ssh/authorized_keys"

echo "Running Post PVE Install script..."
ssh -t root@x79pve 'bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/misc/post-pve-install.sh)"'
sleep 20
until [ $(ssh-keyscan $hostname >/dev/null 2>&1)$? -eq 0 ]; do echo "waiting for reboot to complete..."; sleep 1; done

echo "Running Post Setup PVE script..."
curl -s "https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/post-setup-pve.sh" \
     | ssh root@$hostname bash -s

echo "Setting up GPU passthrough..."
cat > /etc/udev/rules.d/99-gpu-chmod666.rules << 'EOF'
KERNEL=="renderD128", MODE="0666"
KERNEL=="kfd", MODE="0666"
KERNEL=="kfd", GROUP="render", MODE="0666" 
KERNEL=="card0", MODE="0666"
EOF
udevadm control --reload-rules && udevadm trigger

# create containers