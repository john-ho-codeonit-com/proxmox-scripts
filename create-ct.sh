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

# optional
description=""
vmid=
memory=1024
password="qwerty#123"
gpu_passthrough=false
enable_desktop=false
enable_gpu_passthrough=false

# non-configurable
ct_ssh_public_keys="/home/john/.ssh/pve-ct_id_ed25519.pub"
ostype="debian"
rootfs="volume=vm:4"
storage="vm"
lxc_cgroup2_devices_allow_list="c 226:0 rwm|c 226:128 rwm|c 234:* rwm"
lxc_mount_entry_list="/dev/dri dev/dri none bind,optional,create=dir|/dev/dri/renderD128 dev/renderD128 none bind,optional,create=file|/dev/kfd dev/kfd none bind,optional,create=file"
cores=12
cpulimit=12
swap=0
net0="name=eth0,firewall=1,ip=dhcp,bridge=vmbr0,type=veth"
features="nesting=1"
ssh_public_keys="/root/.ssh/authorized_keys"
template="vm:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"

usage() {
  cat - >&2 <<EOF
NAME
    ${CMD:=${0##*/}} - Create a container
 
SYNOPSIS
    ${CMD:=${0##*/}} [-h|--help]
                     --hostname=<arg>
                     [--description=<arg>]
                     [--vmid=<arg>]
                     [--memory=<arg>]
                     [--password=<arg>]
                     [--enable-gpu-passthrough]
                     [--enable-desktop]

OPTIONS
  -h, --help
          Prints this and exits

  --hostname=<arg>
        hostname for container
 
  --description=<arg>
        description for container

  --vmid=<arg>
        vmid for container, will be the cluster nexid if not specified
  
  --memory=<arg>
        memory for container in MB, will be 1024MB if not specified

  --password=<arg>
        password for container root user, will be qwerty#123 if not specified
 
  --enable-gpu-passthrough
        enables gpu passthrough if specified

  --enable-desktop
        add enable desktop and xrdp
  
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
        enable-desktop) enable_desktop=true ;;
        -) # long option processing
            case "$OPTARG" in
                help) usage; exit 0 ;;
                enable-desktop) enable_desktop=true ;;
                enable-gpu-passthrough) enable_gpu_passthrough=true ;;
                hostname|hostname=*) next_arg
                    hostname="$OPTARG" ;;
                description|description=*) next_arg
                    description="$OPTARG" ;;
                vmid|vmid=*) next_arg
                    vmid="$OPTARG" ;;
                memory|memory=*) next_arg
                    memory="$OPTARG" ;;
                password|password=*) next_arg
                    password="$OPTARG" ;;
                -) break ;;
                *) fatal "Unknown option '--${OPTARG}'" "see '${0} --help' for usage" ;;
            esac
            ;;
        *) fatal "Unknown option: '-${OPTARG}'" "See '${0} --help' for usage" ;;
    esac
done

fatal() {
    for i; do
        echo -e "${i}" >&2
    done
    exit 1
}

shift $((OPTIND-1))

# check_script_running

if [ -z "${hostname}" ]; then
    fatal "hostname is required"
fi

if [ -z "${vmid}" ]; then
    vmid=$(pvesh get /cluster/nextid)
fi


echo "vmid: $vmid"
echo "template: $template"

pct create $vmid $template \
  --hostname $hostname \
#   --description $description \
  --cores $cores \
  --cpulimit $cpulimit \
  --memory $memory \
  --swap $swap \
  --features nesting=1 \
  --net0 name=eth0,firewall=1,ip=dhcp,bridge=vmbr0,type=veth \
  --ostype $ostype \
  --password $password \
  --rootfs $rootfs \
  --storage $storage \
  --unprivileged 1 \
  --ssh-public-keys $ssh_public_keys \
  --start 1

# # TODO: check to see if vmid exists
# sleep 5

# until [[ $(pct status $vmid | awk '{print $2}') == "running" ]]; do echo "waiting for container to start"; sleep 1; done

# sleep 5

# ssh-keygen -f ~/.ssh/known_hosts -R $hostname

# cat $ct_ssh_public_keys | ssh root@$hostname -oStrictHostKeyChecking=accept-new 'cat >> /root/.ssh/authorized_keys'

# sed -i 's/#\?\(PermitRootLogin\s*\).*$/\1 without-password/' /etc/ssh/sshd_config
# ssh root@$hostname service sshd restart

# curl -s https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/setup-ct.sh | ssh root@$hostname 'bash -s -- --user_password=$password --enable-desktop=$enable_desktop'

# if ! [ -z "${enable_gpu_passthrough}" ]; then
#     apt install radeontop -y
#     pct shutdown $vmid
#     until [[ $(pct status $vmid | awk '{print $2}') == "stopped" ]]; do echo "waiting for container to start"; sleep 1; done
#     IFS='|' read -a lxc_cgroup2_devices_allow_list_array <<< "$lxc_cgroup2_devices_allow_list" 
#     for lxc_cgroup2_devices_allow in "${lxc_cgroup2_devices_allow_list_array[@]}"; do 
#         echo "$lxc_cgroup2_devices_allow" >> /etc/pve/lxc/$vmid
#     done
#     IFS='|' read -a lxc_mount_entry_list_array <<< "$lxc_mount_entry_list" 
#     for lxc_mount_entry in "${lxc_mount_entry_list_array[@]}"; do 
#         echo "$lxc_mount_entry" >> /etc/pve/lxc/$vmid
#     done
#     pct start $vmid
# fi