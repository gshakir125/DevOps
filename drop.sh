#!/bin/bash
set -e

dropFile=$1
devOpsDir="DevOps"

unzip -o drop/$dropFile.zip -d $devOpsDir/nginx/static/$dropFile

command cd $devOpsDir
if [ -d .git ]; then
    docker-compose -f docker-compose.yml -f docker-compose.qa.yml restart nginx
fi
exit 0