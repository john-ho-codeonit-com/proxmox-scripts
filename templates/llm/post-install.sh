#!/usr/bin/env bash

(cd /opt/stacks/default && until [ "$(docker inspect -f {{.State.Status}} $(docker compose ps -q ollama))" = "running" ]; do echo "waiting for container to start..."; sleep 1; done)
docker exec ollama ollama pull deepseek-r1:14b