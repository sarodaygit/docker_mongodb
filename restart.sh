#!/bin/bash

# Usage:
#   ./restart.sh start dev
#   ./restart.sh shutdown prod

ACTION=$1
ENV=$2

if [[ "$ACTION" != "start" && "$ACTION" != "shutdown" ]]; then
  echo "Usage: $0 {start|shutdown} {dev|prod}"
  exit 1
fi

if [[ "$ENV" != "dev" && "$ENV" != "prod" ]]; then
  echo "Usage: $0 {start|shutdown} {dev|prod}"
  exit 1
fi

if [[ "$ENV" == "dev" ]]; then
  COMPOSE_FILE="docker-compose.dev.yml"
  PROJECT_NAME="dev_project"
elif [[ "$ENV" == "prod" ]]; then
  COMPOSE_FILE="docker-compose.prod.yml"
  PROJECT_NAME="prod_project"
fi

if [[ "$ACTION" == "shutdown" ]]; then
  docker-compose -p $PROJECT_NAME -f $COMPOSE_FILE down
elif [[ "$ACTION" == "start" ]]; then
  docker-compose -p $PROJECT_NAME -f $COMPOSE_FILE up -d --remove-orphans
fi

# docker-compose -f docker-compose.prod.yml down
# docker-compose -f docker-compose.prod.yml up -d --remove-orphans


# docker-compose -p test_project -f docker-compose.dev.yml down
# docker-compose -p test_project -f docker-compose.prod.yml down

# docker-compose -p dev_project -f docker-compose.dev.yml up -d
# docker-compose -p prod_project -f docker-compose.prod.yml up -d