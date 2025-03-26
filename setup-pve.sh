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
ssh_public_key=
user=

# defaults
root_password="qwerty#123"
user_password="qwerty#123"
gpu_passthrough_enabled=0

# non-configurable
template=debian-12-standard_12.7-1_amd64.tar.zst

usage() {
  cat - >&2 <<EOF
NAME
    ${CMD:=${0##*/}} - Setup Proxmox server
 
SYNOPSIS
    ${CMD:=${0##*/}} [-h|--help]
                     --hostname=<arg>
                     --ssh-public-key=<arg>
                     [--root_password=<arg>]
                     --user=<arg>
                     [--user-password=<arg>]
                     [--gpu_passthrough_enabled]

OPTIONS
  -h, --help
          Prints this and exits

  --hostname=<arg>
          hostname, required

  --ssh-public-key=<arg>
          ssh public key, required

  --root-password=<arg>
          root password, defaults to $root_password
  
  --user-password=<arg>
          user password, defaults to $user_password
  
  --user=<arg>
          user, required

  --gpu-passthrough-enabled
          setup gpu passthrough, defaults to disabled

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
                ssh-public-key|ssh-public-key=*) next_arg
                    ssh_public_key="$OPTARG" ;;
                root-password|root-password=*) next_arg
                    root_password="$OPTARG" ;;
                user|user=*) next_arg
                    user="$OPTARG" ;;
                user-password|user-password=*) next_arg
                    user_password="$OPTARG" ;;
                gpu-passthrough-enabled) gpu_passthrough_enabled=1 ;;
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

if [ -z "$ssh_public_key" ]; then
     fatal "ssh-public-key is required"
fi

if [ -z "$user" ]; then
     fatal "user is required"
fi

echo "Setting up ssh key"
ssh-keygen -f ~/.ssh/known_hosts -R $hostname
echo "$ssh_public_key" | sshpass -p $root_password ssh root@$hostname -oStrictHostKeyChecking=accept-new 'cat >> /root/.ssh/authorized_keys'
sshpass -p $user_password ssh root@$hostname "cat /root/.ssh/authorized_keys"

echo "Running Post PVE Install script..."
ssh -t root@x79pve 'bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/misc/post-pve-install.sh)"'
sleep 20
until [ $(ssh-keyscan $hostname >/dev/null 2>&1)$? -eq 0 ]; do echo "waiting for reboot to complete..."; sleep 1; done

echo  "Installing PVE LXC IP-Tag..."
ssh -t root@$hostname 'bash -c "$(wget -qLO - https://github.com/community-scripts/ProxmoxVE/raw/main/misc/add-lxc-iptag.sh)"'

echo  "Installing Ultimate Updater for PVE..."
ssh -t root@$hostname 'bash -c "$(wget -qLO - https://raw.githubusercontent.com/BassT23/Proxmox/master/install.sh)"'

echo "Running Post Setup PVE script..."
curl -s "https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/post-setup-pve.sh" \
     | ssh root@$hostname bash -s

if [ $gpu_passthrough_enabled -eq 1 ]; then
     echo "Setting up GPU passthrough..."
     cat > /etc/udev/rules.d/99-gpu-chmod666.rules << 'EOF'
KERNEL=="renderD128", MODE="0666"
KERNEL=="kfd", MODE="0666"
KERNEL=="kfd", GROUP="render", MODE="0666" 
KERNEL=="card0", MODE="0666"
EOF
     udevadm control --reload-rules && udevadm trigger
fi
