bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/misc/post-pve-install.sh)"

curl --create-dirs -O --output-dir /usr/local/sbin --ouput pve-shutdown https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/pve-shutdown
chmod 777 /usr/local/sbin/pve-shutdown
echo "0 1 * * * root /usr/local/sbin/pve-shutdown" > /etc/cron.d/pve-shutdown

bash <(curl -s https://raw.githubusercontent.com/BassT23/Proxmox/master/install.sh)
echo "0 0 * * * root /usr/local/sbin/update -s" > /etc/cron.d/update

service cron restart

# TODO: create storage containers
pveam update
pveam download containers debian-12-standard_12.7-1_amd64.tar.zst