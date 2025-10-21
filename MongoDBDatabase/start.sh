#!/usr/bin/env sh
# Helper script to start MongoDB via docker-compose for local development.
# Safe defaults; does not require credentials and does not cd into any folder.

set -eu

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Ensure docker-compose v2 invocation works
if command -v docker-compose >/dev/null 2>&1; then
  docker-compose up -d --build
else
  docker compose up -d --build
fi

echo "MongoDB container started (or already running)."
