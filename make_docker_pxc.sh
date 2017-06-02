#!/bin/bash
echo USAGE:
echo "- first argument : path to PXC docker-compose project (for N nodes)"
echo "- second argument: 'up' or 'down'"
echo "- third argument : number of nodes"
echo

if [ "$#" -ne 3 ]; then
  echo "ERROR: Illegal number of parameters."
  exit 1
fi

PXC_COMPOSE_PATH=${1}
UP_OR_DOWN=${2}
NR_NODES=${3}

if [ ! -d "${PXC_COMPOSE_PATH}" ]; then
  echo "ERROR: path to PXC is not a valid directory."
  exit 1
fi

if [ "${UP_OR_DOWN}" != "up" ] && [ "${UP_OR_DOWN}" != "down" ]; then
  echo "ERROR: second argument should be either 'up' or 'down'."
  exit 1
fi

ONLY_DIGITS_REGEX="^[[:digit:]]+$"
if [[ ${NR_NODES} =~ ${ONLY_DIGITS_REGEX} ]]; then
    if [[ ${NR_NODES} -ge 1 ]]; then
        NR_NODES=$((${NR_NODES}-1))
    else
        echo "Number of nodes should be a positive integer."
        exit 1
    fi
else
    echo "Number of nodes argument should contain only digits."
    exit 1
fi

cd $PXC_COMPOSE_PATH;

echo "Setting COMPOSE_PROJECT_NAME in .env file..."
echo


NAME=`whoami`
PWD_MD5=`pwd|md5sum`
NAME="${NAME}.${PWD_MD5:1:6}"

grep -v COMPOSE_PROJECT_NAME .env > .env.swp
echo COMPOSE_PROJECT_NAME=${NAME} >> .env.swp
mv .env.swp .env

echo "PROJECT NAME: ${NAME}"


if [ "${UP_OR_DOWN}" == "up" ]; then
  sudo docker-compose up -d node01
  echo "Waiting 10 seconds for first node to be up..."
  sleep 5;
  for i in `seq ${NR_NODES}`; do
    echo "Brining node $((${i}+1)) up..."
    sudo docker-compose scale nodeN=${i}
    sleep 5;
   done;

  echo
  echo "Use the following commands to access BASH, MYSQL and the logs in the containers:"
  echo 
  for container in `sudo docker-compose ps|grep Up|awk '{print $1}'`; do
    echo sudo docker exec -it $container bash
    echo sudo docker exec -it $container mysql -uroot -proot
    echo sudo docker logs -f $container
    echo
  done;

else 
  if [ "${UP_OR_DOWN}" == "down" ]; then
    echo "Stopping containers and cleaning up..."
    sudo docker-compose down
  fi
fi

exit 0
