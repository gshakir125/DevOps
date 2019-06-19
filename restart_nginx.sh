#!/bin/bash
set -e
devOpsDir="DevOps"
command cd $devOpsDir
if [ -d .git ]; then
    docker-compose -f docker-compose.yml -f docker-compose.qa.yml restart nginx
fi
