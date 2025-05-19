#!/bin/bash

# Usage:
#   ./restart.sh start dev
#   ./restart.sh shutdown prod
#   ./restart.sh status all
#   ./restart.sh cleanstart dev

ACTION=$1
ENV=$2

VALID_ENVS=("dev" "prod" "all")

if [[ "$ACTION" != "start" && "$ACTION" != "shutdown" && "$ACTION" != "status" && "$ACTION" != "cleanstart" ]]; then
  echo "❌ Usage: $0 {start|shutdown|status|cleanstart} {dev|prod|all}"
  exit 1
fi

if [[ ! " ${VALID_ENVS[@]} " =~ " $ENV " ]]; then
  echo "❌ Environment must be one of: dev, prod, all"
  exit 1
fi

# Environment config maps
declare -A COMPOSE_FILES=( ["dev"]="docker-compose.dev.yml" ["prod"]="docker-compose.prod.yml" )
declare -A PROJECT_NAMES=( ["dev"]="dev_project" ["prod"]="prod_project" )
declare -A CONFLICT_CONTAINERS=( ["dev"]="mongodb-dev" ["prod"]="mongodb-prod" )

handle_env() {
  local ACTION=$1
  local ENV=$2
  local FILE=${COMPOSE_FILES[$ENV]}
  local PROJECT=${PROJECT_NAMES[$ENV]}
  local CONTAINER=${CONFLICT_CONTAINERS[$ENV]}

  if [[ ! -f "$FILE" ]]; then
    echo "❌ Compose file $FILE not found!"
    return
  fi

  if [[ "$ACTION" == "shutdown" ]]; then
    echo "🛑 Shutting down $ENV..."
    docker-compose -p "$PROJECT" -f "$FILE" down --remove-orphans
    echo "✅ $ENV shut down."

  elif [[ "$ACTION" == "start" ]]; then
    echo "🚀 Starting $ENV (preserving volumes)..."
    docker-compose -p "$PROJECT" -f "$FILE" down --remove-orphans

    if docker ps -a --format '{{.Names}}' | grep -wq "$CONTAINER"; then
      echo "⚠️  Removing conflicting container: $CONTAINER"
      docker rm -f "$CONTAINER"
    fi

    docker-compose -p "$PROJECT" -f "$FILE" up -d --remove-orphans
    echo "✅ $ENV environment started."

  elif [[ "$ACTION" == "cleanstart" ]]; then
    echo "🧨 Clean starting $ENV (including volume wipe)..."
    docker-compose -p "$PROJECT" -f "$FILE" down --volumes --remove-orphans

    if docker ps -a --format '{{.Names}}' | grep -wq "$CONTAINER"; then
      echo "⚠️  Removing conflicting container: $CONTAINER"
      docker rm -f "$CONTAINER"
    fi

    docker-compose -p "$PROJECT" -f "$FILE" up -d --remove-orphans
    echo "✅ $ENV clean started (fresh volumes)."

  elif [[ "$ACTION" == "status" ]]; then
    echo "📦 Docker status for $ENV:"
    docker-compose -p "$PROJECT" -f "$FILE" ps
  fi
}

# Run for one or both environments
if [[ "$ENV" == "all" ]]; then
  handle_env "$ACTION" "dev"
  handle_env "$ACTION" "prod"
else
  handle_env "$ACTION" "$ENV"
fi
