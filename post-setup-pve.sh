echo "Install packages..."
apt-get install sudo -y

email=john.ho@codeonit.com
domain=proxmoxx79.codeonit.com

# create function
echo "Setting up SSL..."
echo "Setting up SSL for staging..."
pvenode acme account register Staging $email

echo "Configure the DNS validation plugin..."
echo 'NameCheap_Token=12345678-abcd-1234-5678-1234567890ab' > ~/api_data
pvenode acme plugin add dns namecheap-challenge --api namecheap --data ~/api_data
pvenode config set --acmedomain0 $domain,plugin=namecheap-challenge
pvenode config set --acme account=staging
pvenode acme cert order
echo "" | openssl s_client -connect $domain:8006 2> /dev/null | sed -n -e '/BEGIN\ CERTIFICATE/,/END\ CERTIFICATE/ p' | openssl x509 -noout -issuer -subject -dates -in -

echo "Setting up SSL for production..."
pvenode acme account register Production $email
pvenode config set --acme account=production
pvenode acme cert order
echo "" | openssl s_client -connect $domain:8006 2> /dev/null | sed -n -e '/BEGIN\ CERTIFICATE/,/END\ CERTIFICATE/ p' | openssl x509 -noout -issuer -subject -dates -in -

echo "Setting up TFA for root..."
ROOT_OATHKEYID=$(oathkeygen) && echo -e OATH key ID for root: $OATHKEYID && qrencode -t ANSIUTF8 -o - $(echo "otpauth://totp/PVE:root@"$(hostname --fqdn)"?secret=$OATHKEYID")
pveum user modify root@pam --keys $ROOT_OATHKEYID

echo "Creating user..."
$user=john
$user_password
useradd -m -s /bin/zsh $user
usermod -aG sudo $user
echo $user:$user_password | chpasswd
pveum acl modify / --roles PVEAdmin --users john@pam

echo "Setting up TFA for user..."
USER_OATHKEYID=$(oathkeygen) && echo -e OATH key ID for $user: $OATHKEYID && qrencode -t ANSIUTF8 -o - $(echo "otpauth://totp/PVE:$user@"$(hostname --fqdn)"?secret=$OATHKEYID")
pveum user modify $user@pam --keys $USER_OATHKEYID

echo "Enforcing TFA..."
sudo pveum realm modify pam --tfa type=oath

# TODO:  setup ACME let's encrypt

echo  "Setting up pve-shutdown cron job..."
curl --create-dirs -O --output-dir /usr/local/sbin https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/pve-shutdown
chmod 777 /usr/local/sbin/pve-shutdown
echo "0 1 * * * root /usr/local/sbin/pve-shutdown" > /etc/cron.d/pve-shutdown

echo  "Setting up update cron job..."
bash <(curl -s https://raw.githubusercontent.com/BassT23/Proxmox/master/install.sh)
echo "0 0 * * * root /usr/local/sbin/update -s" > /etc/cron.d/update
service cron restart

pool=storage
echo  "Setting up zfs pool..."
wipefs --force --all /dev/nvme0n1
zpool create -f -o ashift=12 $pool /dev/nvme0n1
zfs set compression=lz4 $pool

echo "Creating zfs pool directories..."
zfs create $pool/isos
zfs create $pool/containers
zfs create $pool/vms
zfs create $pool/backups
pvesm add dir ISOs --path /$pool/isos --content iso,vztmpl
pvesm add dir Containers --path /$pool/containers --content rootdir
pvesm add dir VMs --path /$pool/vms --content images
pvesm add dir Backups --path /$pool/backups --content backup,snippets

echo "Download container templates..."
pveam update
pveam download ISOs debian-12-standard_12.7-1_amd64.tar.zst