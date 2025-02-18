bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/misc/post-pve-install.sh)"

curl --create-dirs -O --output-dir /usr/local/sbin https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/pve-shutdown
chmod 777 /usr/local/sbin/pve-shutdown
echo "0 1 * * * root /usr/local/sbin/pve-shutdown" > /etc/cron.d/pve-shutdown

bash <(curl -s https://raw.githubusercontent.com/BassT23/Proxmox/master/install.sh)
echo "0 0 * * * root /usr/local/sbin/update -s" > /etc/cron.d/update

service cron restart

wipefs --force --all /dev/nvme0n1

pool=storage
zpool create -f -o ashift=12 $pool /dev/nvme0n1
zfs set compression=lz4 $pool
zfs create $pool/isos
zfs create $pool/containers
zfs create $pool/vms
zfs create $pool/backups

pvesm add dir ISOs --path /$pool/isos --content iso,vztmpl
pvesm add dir Containers --path /$pool/containers --content rootdir
pvesm add dir VMs --path /$pool/vms --content images
pvesm add dir Backups --path /$pool/backups --content backup,snippets

pveam update
pveam download ISOs debian-12-standard_12.7-1_amd64.tar.zst