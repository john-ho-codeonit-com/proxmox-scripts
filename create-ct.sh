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
package_url=
env=
size=4
volume="Containers"
isos_volume=ISOs
ssh_public_key=
CT_SETUP_GPU_PASSTHROUGH_ENABLED=0

# non-configurable
ostype="debian"
storage="vm"
lxc_cgroup2_devices_allow_list="c 226:0 rwm|c 226:128 rwm|c 234:* rwm"
lxc_mount_entry_list="/dev/dri dev/dri none bind,optional,create=dir|/dev/dri/renderD128 dev/renderD128 none bind,optional,create=file|/dev/kfd dev/kfd none bind,optional,create=file"
cores=12
cpulimit=12
swap=0
net0="name=eth0,firewall=1,ip=dhcp,bridge=vmbr0,type=veth"
features="nesting=1"
ssh_public_keys="/root/.ssh/authorized_keys"
net0="name=eth0,firewall=1,ip=dhcp,bridge=vmbr0,type=veth"
setup_ct_script_url="https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/setup-ct.sh"


usage() {
  cat - >&2 <<EOF
NAME
    ${CMD:=${0##*/}} - Create a container
 
SYNOPSIS
    ${CMD:=${0##*/}} [-h|--help]
                     --hostname=<arg>
                     --ssh-public-key
                     [--description=<arg>]
                     [--vmid=<arg>]
                     [--memory=<arg>]
                     [--size=<arg>]
                     [--password=<arg>]
                     [--package-url=<arg>]
                     [--package-env=<arg>]

OPTIONS
  -h, --help
          Prints this and exits

  --hostname=<arg>
        hostname for container, required
  
  --ssh-public-key=<arg>
        ssh authorized key, required
 
  --description=<arg>
        description for container

  --vmid=<arg>
        vmid for container, will be the cluster nexid if not specified
  
  --memory=<arg>
        memory for container in MB, will be 1024MB if not specified

  --size=<arg>
        storage size for container in GB, will be 15GB if not specified

  --volume=<arg>
        rootfs volume to be used, will be Containers if not specified

  --isos-volume=<arg>
        ISOs volume to be used for the template, will be ISOs if not specified

  --password=<arg>
        password for container root user, will be qwerty#123 if not specified

  --package-url=<arg>
        package url to setup ct

  --package-env=<arg>
        package env as a json string to setup ct
  
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
                description|description=*) next_arg
                    description="$OPTARG" ;;
                vmid|vmid=*) next_arg
                    vmid="$OPTARG" ;;
                memory|memory=*) next_arg
                    memory="$OPTARG" ;;
                size|size=*) next_arg
                    size="$OPTARG" ;;
                volume|volume=*) next_arg
                    volume="$OPTARG" ;;
                isos-volume|isos-volume=*) next_arg
                    isos_volume="$OPTARG" ;;
                password|password=*) next_arg
                    password="$OPTARG" ;;
                package-url|package-url=*) next_arg
                    package_url="$OPTARG" ;;
                package-env|package-env=*) next_arg
                    package_env="$OPTARG" ;;
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

if [ -z "$hostname" ]; then
    fatal "hostname is required"
fi

if [ -z "$ssh_public_key" ]; then
    fatal "ssh-public-key is required"
fi

# if [ "$package_env" ]; then
#     if ! jq -e . >/dev/null 2>&1 <<<"$package_env"; then
#         fatal "package-env json string is invalid"
#     fi
# fi

if [ -z "$vmid" ]; then
    vmid=$(pvesh get /cluster/nextid)
fi

if [ -z "$description" ]; then
    description=$hostname
fi

template="$isos_volume:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"

echo "Creating container..."
pct create $vmid $template \
  --hostname $hostname \
  --description $description \
  --cores $cores \
  --cpulimit $cpulimit \
  --memory $memory \
  --swap $swap \
  --features $features \
  --net0 $net0 \
  --ostype $ostype \
  --password $password \
  --rootfs "volume=$volume:$size" \
  --storage $storage \
#   --unprivileged 0 \
  --ssh-public-keys $ssh_public_keys \
  --start 1

until [ -f "/etc/pve/lxc/$vmid.conf" ]; do echo "waiting for container to be created..."; sleep 1; done
until [ $(pct status $vmid | awk '{print $2}') == "running" ]; do echo "waiting for container to start..."; sleep 1; done
until [ $(ssh-keyscan $hostname >/dev/null 2>&1)$? -eq 0 ]; do echo "waiting for container to start..."; sleep 1; done

pct set $vmid -onboot 1

echo "Setting up ssh keys..."
ssh-keygen -f ~/.ssh/known_hosts -R $hostname

echo "$ssh_public_key" | ssh root@$hostname -oStrictHostKeyChecking=accept-new 'cat >> /root/.ssh/authorized_keys'

sed -i 's/#\?\(PermitRootLogin\s*\).*$/\1 without-password/' /etc/ssh/sshd_config

if [ "$package_url" ]; then
    echo "Getting package..."
    source /dev/stdin <<< $(curl -s $package_url/default.env)
fi

if [ $CT_SETUP_GPU_PASSTHROUGH_ENABLED -eq 1 ]; then
    echo "Setting up gpu passthrough..."
    pct shutdown $vmid
    until [[ $(pct status $vmid | awk '{print $2}') == "stopped" ]]; do echo "waiting for container to stop"; sleep 1; done
    IFS='|' read -a lxc_cgroup2_devices_allow_list_array <<< "$lxc_cgroup2_devices_allow_list" 
    for lxc_cgroup2_devices_allow in "${lxc_cgroup2_devices_allow_list_array[@]}"; do 
        echo "lxc.cgroup2.devices.allow: $lxc_cgroup2_devices_allow" >> "/etc/pve/lxc/$vmid.conf"
    done
    IFS='|' read -a lxc_mount_entry_list_array <<< "$lxc_mount_entry_list" 
    for lxc_mount_entry in "${lxc_mount_entry_list_array[@]}"; do 
        echo "lxc.mount.entry: $lxc_mount_entry" >> "/etc/pve/lxc/$vmid.conf"
    done
    pct start $vmid
    until [ $(pct status $vmid | awk '{print $2}') == "running" ]; do echo "waiting for container to start..."; sleep 1; done
fi

setup_ct_args="--user-password=$password"

if [ "$package_url" ]; then
    setup_ct_args+=" --package-url='$package_url'"
fi

if [ "$package_env" ]; then
    setup_ct_args+=" --package-env='$package_env'"   
fi

curl -s $setup_ct_script_url | ssh root@$hostname bash -s -- $setup_ct_args

ssh root@$hostname service sshd restart