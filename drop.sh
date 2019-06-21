#!/bin/bash
set -e

dropFile=$1
dropDir=$2
devOpsDir="DevOps"

unzip -o drop/$dropFile.zip -d $devOpsDir/nginx/static/$dropDir

command cd $devOpsDir
if [ -d .git ]; then
    docker-compose -f docker-compose.yml -f docker-compose.qa.yml restart nginx
fi
exit 0