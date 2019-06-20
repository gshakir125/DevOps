#!/bin/bash
set -e

# ssh afarooq@13.75.70.241 "envariable=Value bash -s" < deploy.sh 4 arguments
# PowerShellpl Get-Content ./deploy.sh -Raw | ssh afarooq@52.184.15.199 'bash -s'
# cd /drives/d/repos/DevOps
# ./plink.exe afarooq@52.184.15.199 -batch -pw P@kistan7861 "bash -s" < deploy.sh "world"
# ssh afarooq@13.75.70.241 "bash -s" < deploy.sh "World"
# ssh afarooq@13.75.70.241 < deploy.sh
# ssh afarooq@13.75.70.241  "$(<"deploy.sh)"
# ssh afarooq@13.75.70.241 "numr=Value bash -s" < deploy.sh
# ssh afarooq@13.75.70.241 export DEMO_VAR=Value asdf \; "$(<deploy.sh)"
# sudo COMPOSE_OPTIONS="-e DEMO_VAR=$DEMO_VAR" docker-compose up some_server

# cat >>~/.netrc <<EOF
# machine https://afarooq@dev.azure.com/afarooq/Svg2Font/_git/Svg2Font.DevOps
#        login $username
#        password $password
# EOF

if [[ $# -lt 4 ]] ; then
    echo 'All arguments are not supplied'
    exit 1
fi

environment=$1
projectName=$2
serviceName=$3
devOpsRepo=$4
dockerUrl=$5

dockerRepo="$dockerUrl/$serviceName:latest"

echo " "
echo "Envirnment:           $environment"
echo "Project:              $projectName"
echo "Service:              $serviceName"
echo "DevOps Repository:    $devOpsRepo"
echo "Docker Repository:    $dockerUrl"
echo " "

export COMPOSE_INTERACTIVE_NO_CLI=1
devOpsDir="DevOps"
projectDir="$devOpsDir/$projectName"

install_docker() {
    # Docker
    sudo apt remove --yes docker docker-engine docker.io \
    && sudo apt update \
    sudo apt update \
    && sudo apt --yes --no-install-recommends install \
    apt-transport-https \
    ca-certificates \
    && wget --quiet --output-document=- https://download.docker.com/linux/ubuntu/gpg \
    | sudo apt-key add - \
    && sudo add-apt-repository \
    "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu \
        $(lsb_release --codename --short) \
    stable" \
    && sudo apt update \
    && sudo apt --yes --no-install-recommends install docker-ce \
    && sudo usermod --append --groups docker "$USER" \
    && sudo chown "$USER":"$USER" /home/"$USER"/.docker -R \
    && sudo chmod g+rwx "/home/$USER/.docker" -R \
    && sudo systemctl enable docker \
    && printf '\nDocker installed successfully\n\n'
    
    printf 'Waiting for Docker to start...\n\n'
    sleep 3
    
    # Docker Compose
    sudo wget \
    --output-document=/usr/local/bin/docker-compose \
    https://github.com/docker/compose/releases/download/1.24.0/run.sh \
    && sudo chmod +x /usr/local/bin/docker-compose \
    && sudo wget \
    --output-document=/etc/bash_completion.d/docker-compose \
    "https://raw.githubusercontent.com/docker/compose/$(sudo docker-compose version --short)/contrib/completion/bash/docker-compose" \
    && printf '\nDocker Compose installed successfully\n\n'
    
}
get_environment(){
  local environment=$1
  case "$environment" in
    prod)
      echo "prod.yml"
    ;;
    qa)
      echo "qa.yml"
    ;;
    *)
      echo "yml"
    ;;
  esac
}
download_devops(){
    local dir=$1
    echo "Downloading DevOps repo"
    git init $dir
    command cd $dir
    git remote add -t \* -f origin $devOpsRepo  
    git checkout master
    docker-compose -f docker-compose.yml -f docker-compose.qa.yml up -d nginx
    if [ "$?" -ne 0 ]; then
      echo "Error in DevOps Up and Running !" 1>&2
      exit 1
    fi
}
check_devops_changes(){
  local dir=$1

  # Check DevOps folder exists
  if [ ! -d "$dir" ]; then
    download_devops $dir
  else
      command cd "$dir"
      # Check if folder is git repository
      if [ ! -d .git ]; then
         # Download git in current directory
         download_devops .
      else
         git fetch

         # Check if there needs an update in DevOps
         if [ $(git rev-parse HEAD) != $(git rev-parse @{u}) ]; then
            git pull
         else
            echo "Dev Ops is up to date"
            docker-compose -f docker-compose.yml -f docker-compose.qa.yml up -d nginx
         fi
      fi
  fi
  command cd
}

env=$(get_environment $environment)

# Check if Docker is installed
if [ -x "!$(command -v docker)" ]; then
    echo "Installing docker..."
    install_docker
fi


check_devops_changes $devOpsDir
command cd $projectDir
output=$(docker pull $dockerRepo | tee /dev/stderr)

if [[ $output != *"up to date"* ]]; then # Not up to date
    success=$(docker-compose -f docker-compose.yml -f docker-compose.$env up -d --force-recreate --build $serviceName)
    if (( success != 0 )); then
      echo "Error in Running Service"
      exit 1
    fi
else
  docker-compose -f docker-compose.yml -f docker-compose.$env up -d $serviceName
fi

exit 0