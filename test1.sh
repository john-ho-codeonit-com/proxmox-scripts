#!/usr/bin/env bash

docker_stacks_path=/opt/stacks
docker_default_stack_path="$docker_stacks_path/default"
package_url="https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/templates/caddy"
source /dev/stdin <<< $(curl -s $package_url/default.env)
echo "Installing and running docker compose app..."
mkdir -p $docker_default_stack_path
if [ $"CT_SETUP_DOWNLOAD_FILES" ]; then
    echo "Downloading files..."
    download_file_array=$(echo "$CT_SETUP_DOWNLOAD_FILES" | jq -r -c '.[]')
    IFS=$'\n'
    for download_file in ${download_file_array[@]}; do
        file=$(jq -r '.file' <<< "$download_file")
        dest=$(jq -r '.dest' <<< "$download_file")
        echo ...$file...
        echo ...$dest...
        mkdir -p $docker_default_stack_path/$dest
        curl "$package_url/$file" --output $docker_default_stack_path/$dest/$file
    done
    unset IFS
fi
touch $docker_default_stack_path/default.env
if curl -sfILo/dev/null "$package_url/default.env"; then
    eval "export $(printf "%s\n" "$package_env" | jq -r 'to_entries | map("\(.key)=\(.value)") | @sh')"
    (cd $docker_default_stack_path && curl "$package_url/default.env" --output default.env && envsubst < default.env | tee default.env)
fi
(cd $docker_default_stack_path && curl "$package_url/compose.yaml" --output compose.yaml && docker compose --env-file default.env up -d)