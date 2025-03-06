#!/usr/bin/env bash

docker_stacks_path=/opt/stacks
docker_default_stack_path="$docker_stacks_path/default"
# package_url="https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/templates/authentik"
# package_env='{"PG_PASS":"zECfDucu9dGi5mtYQwb71lZpxji0hWQtERtMjpQjItCBrmh6","AUTHENTIK_SECRET_KEY":"1kprlKgUGSBPDh1INQBc5k8wpDuReQlQJ3V5hz79A5MjKNCUM/zOZZx9HzH8T7dBfqZy2KdlFFcGDSwA","AUTHENTIK_ERROR_REPORTING__ENABLED":true}'
package_url="https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/templates/caddy"
package_env='{"NAMECHEAP_API_KEY":"a2c3898476b5483cb9ffb1c8308fe2c8","NAMECHEAP_USER":"johnphho","DOCKGE_URL":"dockge:5001","AUTHENTIK_URL":"authentik:9000"}'

if [ "$package_url" ]; then
    echo "Getting package..."
    source /dev/stdin <<< $(curl -s "$package_url/.env")
    echo "...$CT_SETUP_DOWNLOAD_FILES..."
fi

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
touch $docker_default_stack_path/.env
if curl -sfILo/dev/null "$package_url/.env"; then
    eval "export $(printf "%s\n" "$package_env" | jq -r 'to_entries | map("\(.key)=\(.value)") | @sh')"
    curl "$package_url/.env" --output $docker_default_stack_path/.env
    cat $docker_default_stack_path/.env
    envsubst < $docker_default_stack_path/.env | tee $docker_default_stack_path/.env
    # (cd $docker_default_stack_path && curl "$package_url/.env" --output .env && envsubst < .env | tee .env)
fi
# (cd $docker_default_stack_path && curl "$package_url/compose.yaml" --output compose.yaml && docker compose --env-file .env up -d)