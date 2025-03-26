#!/usr/bin/env bash

# check_script_running() {
#     pid=`pgrep -f $0`
#     if ! [[ -z "$pid" ]]; then
#         echo "❌ Script $0 already running with pid $pid.  Please close the running script to run."
#         exit 1
#     fi
# }

# required
hostname=
user=

# defaults
user_password="qwerty#123"

# non-configurable
template=debian-12-standard_12.7-1_amd64.tar.zst
dev_disk=nvme0n1
pool=storage

usage() {
  cat - >&2 <<EOF
NAME
    ${CMD:=${0##*/}} - Post setup Proxmox server
 
SYNOPSIS
    ${CMD:=${0##*/}} [-h|--help]
                     --hostname=<arg>
                     --user=<arg>
                     [--user-password=<arg>]

OPTIONS
  -h, --help
          Prints this and exits

  --hostname=<arg>
          hostname, required

  --user=<arg>
        container user to created

  --user-password=<arg>
        user password, defaults to $user_password

EOF
}

fatal() {
    for i; do
        echo -e "${i}" >&2
    done
    exit 1
}

# For long option processing
next_arg() {
    if [[ $OPTARG == *=* ]]
    then
        # for cases like '--opt=arg'
        OPTARG="${OPTARG#*=}"
    else
        # for cases like '--opt arg'
        OPTARG="${args[$OPTIND]}"
        OPTIND=$((OPTIND + 1))
    fi
}

# ':' means preceding option character expects one argument, except
# first ':' which make getopts run in silent mode. We handle errors with
# wildcard case catch. Long options are considered as the '-' character
optspec=":hfb:-:"
args=("" "$@")  # dummy first element so $1 and $args[1] are aligned
while getopts "$optspec" optchar; do
    case "$optchar" in
        h) usage; exit 0 ;;
        -) # long option processing
            case "$OPTARG" in
                help) usage; exit 0 ;;
                hostname|hostname=*) next_arg
                    hostname="$OPTARG" ;;                
                user|user=*) next_arg
                    user="$OPTARG" ;;
                user-password|user-password=*) next_arg
                    user_password="$OPTARG" ;;
                -) break ;;
                *) fatal "Unknown option '--${OPTARG}'" "see '${0} --help' for usage" ;;
            esac
            ;;
        *) fatal "Unknown option: '-${OPTARG}'" "See '${0} --help' for usage" ;;
    esac
done

shift $((OPTIND-1))

# check_script_running

if [ -z "$hostname" ]; then
     fatal "hostname is required"
fi

if [ -z "$user" ]; then
     fatal "user is required"
fi

echo "Install packages..."
apt-get install sudo -y

echo "Creating user..."
useradd -m -s /bin/zsh $user
usermod -aG sudo $user
echo $user:$user_password | chpasswd
pveum acl modify / --roles PVEAdmin --users $user@pam

echo  "Setting up pve-shutdown cron job..."
curl --create-dirs -O --output-dir /usr/local/sbin https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/pve-shutdown
chmod 777 /usr/local/sbin/pve-shutdown
echo "0 1 * * * root /usr/local/sbin/pve-shutdown" > /etc/cron.d/pve-shutdown

echo  "Setting up update cron job..."
bash <(curl -s https://raw.githubusercontent.com/BassT23/Proxmox/master/install.sh)
echo "0 0 * * * root /usr/local/sbin/update -s" > /etc/cron.d/update
service cron restart

echo  "Setting up zfs pool..."
wipefs --force --all /dev/$dev_disk
zpool create -f -o ashift=12 $pool /dev/$dev_disk
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