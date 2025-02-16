#!/usr/bin/env bash

(cd /opt/stacks/default && until [ "$(docker inspect -f {{.State.Health.Status}} $(docker-compose ps -q ollama))" = "healthy" ]; do sleep 1; done)
docker exec ollama ollama pull deepseek-r1:14b