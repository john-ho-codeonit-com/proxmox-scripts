#!/usr/bin/env bash

# check_script_running() {
#     pid=`pgrep -f $0`
#     if ! [[ -z "$pid" ]]; then
#         echo "❌ Script $0 already running with pid $pid.  Please close the running script to run."
#         exit 1
#     fi
# }

# defaults
docker_compose_url=
post_install_script_url=
user="dockeruser"
user_fullname="Docker User"
user_password="qwerty#123"
enable_gpu_passthrough=false
enable_desktop=false

usage() {
  cat - >&2 <<EOF
NAME
    ${CMD:=${0##*/}} - Checks local environment to run the app
 
SYNOPSIS
    ${CMD:=${0##*/}} [-h|--help]
                     [--user=<arg>]
                     [--user-fullname=<arg>]
                     [--user-password=<arg>]
                     [--docker-compose-url=<arg]
                     [--post-install-script-url=<arg>]
                     [--enable_gpu_passthrough]
                     [--enable-desktop]

OPTIONS
  -h, --help
          Prints this and exits

  --user=<arg>
        container user to created

  --user_fullname=<arg>
        user full name for the container user

  --user_password=<arg>
        user password for the container user

  --docker-compose-url=<arg>
        docker compose file to run

  --post-install-script-url=<arg>
        post install script to run

  --enable-gpu-passthrough
        install gpu apps

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
        enable-gpu-passthrough) enable_gpu_passthrough=true ;;
        -) # long option processing
            case "$OPTARG" in
                help) usage; exit 0 ;;
                enable-desktop) enable_desktop=true ;;
                enable-gpu-passthrough) enable_gpu_passthrough=true ;;
                user|user=*) next_arg
                    user="$OPTARG" ;;
                user-fullname|user-fullname=*) next_arg
                    user_fullname="$OPTARG" ;;
                user-password|user-password=*) next_arg
                    user_password="$OPTARG" ;;
                docker-compose-url|docker-compose-url=*) next_arg
                    docker_compose_url="$OPTARG" ;;
                post-install-script-url|post-install-script-url=*) next_arg
                    post_install_script_url="$OPTARG" ;;
                -) break ;;
                *) fatal "Unknown option '--${OPTARG}'" "see '${0} --help' for usage" ;;
            esac
            ;;
        *) fatal "Unknown option: '-${OPTARG}'" "See '${0} --help' for usage" ;;
    esac
done

shift $((OPTIND-1))

# check_script_running

echo "Upgrading system..."
apt-get update
apt-get upgrade -y

echo "Installing essential packages..."
apt-get install git -y

echo "Install docker..."
apt-get install ca-certificates curl -y
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

echo "Creating user $user..."
apt-get install sudo -y
adduser $user --gecos "$user_fullname,,," --disabled-password
echo "$user:$user_password" | chpasswd
usermod -aG sudo $user
usermod -aG docker $user

echo "Setting up ssh keys for user $user..."
mkdir -p /home/$user/.ssh
cp /root/.ssh/authorized_keys /home/$user/.ssh
chown -R $user:$user /home/$user/.ssh

echo "Installing dockge..."
mkdir -p /opt/stacks /opt/dockge
(cd /opt/dockge && curl "https://raw.githubusercontent.com/louislam/dockge/master/compose.yaml" --output compose.yaml && docker compose up -d)

if [ -n "${docker_compose_url}" ]; then
    echo "Installing and running docker compose app..."
    mkdir -p /opt/stacks/default
    (cd /opt/stacks/default && curl $docker_compose_url --output compose.yaml && docker compose up -d)
fi

if [ -n "${post_install_script_url}" ]; then
    echo "Running post install script..."
    curl -H "Cache-Control: no-cache, no-store, must-revalidate" \
         -H "Pragma: no-cache" \
         -H "Expires: 0" \
         -s "$post_install_script_url" \
         | bash
fi

if [ "${enable_gpu_passthrough}" == "true" ]; then
    echo "Installing gpu packages..."
    apt-get install radeontop -y
fi

if [ "$enable_desktop" == "true" ]; then
    echo "Installing desktop packages and setting up desktop..."
    apt-get install xfce4 xfce4-goodies xorg dbus-x11 x11-xserver-utils -y
    apt-get install xrdp -y
    adduser xrdp ssl-cert
    systemctl restart xrdp
    usermod -aG video $user
    usermod -aG render $user
    usermod -aG audio $user
    usermod -aG input $user
fi