#!/bin/bash
echo USAGE:
echo "- first argument : path to PXC docker-compose project (for 3 nodes)"
echo "- second argument: 'up' or 'down'"
echo

if [ "$#" -ne 2 ]; then
  echo "ERROR: Illegal number of parameters."
  exit 1
fi

PXC_COMPOSE_PATH=${1}
UP_OR_DOWN=${2}

if [ ! -d "${PXC_COMPOSE_PATH}" ]; then
  echo "ERROR: path to PXC is not a valid directory."
  exit 1
fi

if [ "${UP_OR_DOWN}" != "up" ] && [ "${UP_OR_DOWN}" != "down" ]; then
  echo "ERROR: second argument should be either 'up' or 'down'."
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
  echo "Waiting 5 seconds for first node to be up..."
  sleep 5;

  sudo docker-compose up -d node02
  echo "Waiting 5 seconds for second node to be up..."
  sleep 5;

  sudo docker-compose up -d node03
  echo "Waiting 5 seconds for third node to be up..."
  sleep 5;

  echo
  echo "Use the following commands to access BASH, MYSQL, inspect and the logs in the containers:"
  echo 
  for container in `sudo docker-compose ps|grep Up|awk '{print $1}'`; do
    echo sudo docker exec -it $container bash
    echo sudo docker exec -it $container mysql -uroot -proot
    echo sudo docker inspect $container
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
