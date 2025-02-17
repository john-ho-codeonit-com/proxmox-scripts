curl https://raw.githubusercontent.com/community-scripts/ProxmoxVE/refs/heads/main/misc/update-repo.sh | bash

curl 

echo "0 1 * * * root /root/scripts/shutdown.sh" > /etc/cron.d/shutdown

systemctl restart cron

# bash <(curl -s https://raw.githubusercontent.com/BassT23/Proxmox/master/install.sh)
