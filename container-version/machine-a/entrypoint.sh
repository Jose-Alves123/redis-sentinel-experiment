#!/bin/sh
set -e

# Start the inner docker daemon in the background
dockerd-entrypoint.sh &

# Wait until the inner daemon is ready
until docker info >/dev/null 2>&1; do
  echo "Waiting for inner Docker daemon..."
  sleep 1
done

echo "Inner Docker daemon ready. Starting compose stack..."
docker compose -f /app/compose.yml up