#!/usr/bin/env bash

package_env='{"CT_SETUP_CONFIG":{"settings":[{"provider":"namecheap","domain":"@","password":"efb5e9c74db84dfb8440b699b9496047"},{"provider":"namecheap","domain":"apps.codeonit.com","password":"efb5e9c74db84dfb8440b699b9496047"},{"provider":"namecheap","domain":"dockge.codeonit.com","password":"efb5e9c74db84dfb8440b699b9496047"},{"provider":"namecheap","domain":"ddnsupdater.codeonit.com","password":"efb5e9c74db84dfb8440b699b9496047"},{"provider":"namecheap","domain":"prompt.codeonit.com","password":"efb5e9c74db84dfb8440b699b9496047"},{"provider":"namecheap","domain":"code.codeonit.com","password":"efb5e9c74db84dfb8440b699b9496047"}]}}'

docker_stacks_path=/opt/stacks
docker_default_stack_path="$docker_stacks_path/default"

package_url="https://raw.githubusercontent.com/john-ho-codeonit-com/proxmox-scripts/refs/heads/main/templates/ddnsupdater"
source /dev/stdin <<< $(curl -s "$package_url/.env")

if [ "$package_url" ]; then
    echo "Installing and running docker compose app..."
    mkdir -p $docker_default_stack_path
    if [ "$CT_SETUP_DOWNLOAD_FILES" ]; then
        echo "Downloading files..."
        download_file_array=$(echo "$CT_SETUP_DOWNLOAD_FILES" | jq -r -c '.[]')
        IFS=$'\n'
        for download_file in ${download_file_array[@]}; do
            file=$(jq -r '.file' <<< "$download_file")
            dest=$(jq -r '.dest' <<< "$download_file")
            echo ...$file...
            echo ...$dest...
            download_output_file=$docker_default_stack_path/$file
            if [ -n "$dest" ]; then
                mkdir -p $docker_default_stack_path/$dest
                download_output_file=$docker_default_stack_path/$dest/$file
            fi
            echo ...$download_output_file...
            curl "$package_url/$file" --output $download_output_file
        done
        unset IFS
    fi
    touch $docker_default_stack_path/.env
    if curl -sfILo/dev/null "$package_url/.env"; then
        curl "$package_url/.env" --output $docker_default_stack_path/tmp.env
        eval "export $(printf "%s\n" "$package_env" | jq -r 'to_entries | map("\(.key)=\(.value)") | @sh')"
        envsubst < $docker_default_stack_path/tmp.env > $docker_default_stack_path/.env
        # rm $docker_default_stack_path/tmp.env
    fi
    (cd $docker_default_stack_path && curl "$package_url/compose.yaml" --output compose.yaml && docker compose up -d)
fi