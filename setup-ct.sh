#!/usr/bin/env bash

# check_script_running() {
#     pid=`pgrep -f $0`
#     if ! [[ -z "$pid" ]]; then
#         echo "❌ Script $0 already running with pid $pid.  Please close the running script to run."
#         exit 1
#     fi
# }

# TODO:  add environment variables for container

# defaults
package_url=
package_env=
user="dockeruser"
user_fullname="Docker User"
user_password="qwerty#123"

usage() {
  cat - >&2 <<EOF
NAME
    ${CMD:=${0##*/}} - Checks local environment to run the app
 
SYNOPSIS
    ${CMD:=${0##*/}} [-h|--help]
                     --package-url=<arg>
                     [--user=<arg>]
                     [--user-fullname=<arg>]
                     [--user-password=<arg>]
                     [--package-env=<arg>]

OPTIONS
  -h, --help
          Prints this and exits

  --user=<arg>
        container user to created

  --user_fullname=<arg>
        user full name for the container user

  --user_password=<arg>
        user password for the container user

  --package-url=<arg>
        package url required to setup ct
  
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
                user|user=*) next_arg
                    user="$OPTARG" ;;
                user-fullname|user-fullname=*) next_arg
                    user_fullname="$OPTARG" ;;
                user-password|user-password=*) next_arg
                    user_password="$OPTARG" ;;
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

shift $((OPTIND-1))

# check_script_running

if [ -z "$package_url" ]; then
    fatal "package-url is required"
fi

# if [ "$package_env" ]; then
#     if ! jq -e . >/dev/null 2>&1 <<<"$package_env"; then
#         fatal "package-env json string is invalid"
#     fi
# fi

echo "Upgrading system..."
apt-get update
apt-get upgrade -y

echo "Installing essential packages..."
apt-get install git jq -y

echo "Install docker..."
apt-get install ca-certificates curl -y
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
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

echo "Getting package..."
source /dev/stdin <<< $(curl -s $package_url/default.env)

echo "Installing and running docker compose app..."
mkdir -p /opt/stacks/default
chmod 777 /opt/stacks/default
(cd /opt/stacks/default && touch default.env)
if curl -sfILo/dev/null "$package_url/default.env"; then
    eval $(echo "$package_env" | jq -r 'to_entries|map("\(.key)=\(.value|tostring)")|.[]' )
    (cd /opt/stacks/default && curl "$package_url/default.env" --output default.env && envsubst < default.env)
fi
(cd /opt/stacks/default && curl "$docker_compose_url/compose.yaml" --output compose.yaml && docker compose --env-file default.env up -d)

if [ $RUN_POST_INSTALL -eq 1 ]; then
    echo "Running post install script..."
    curl -s $package_url/post-install.sh | bash
fi

if [ $GPU_PASSTHROUGH_ENABLED -eq 1 ]; then
    echo "Installing gpu packages..."
    apt-get install radeontop -y
fi

if [ $DESKTOP_ENABLED -eq 1 ]; then
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