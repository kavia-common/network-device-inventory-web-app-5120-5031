#!/usr/bin/env sh
# A minimal entrypoint that ensures we never cd into non-existent paths.
# Starts mongod by default, or runs any provided command.
set -e

# If the first arg looks like a flag, assume 'mongod'
if [ "${1#-}" != "$1" ]; then
  set -- mongod "$@"
fi

# If explicitly requested, we can no-op to allow preview without DB
if [ "$1" = "noop" ]; then
  echo "[MongoDBDatabase] No-op requested. Container will exit successfully."
  exit 0
fi

# Start MongoDB or run the provided command
exec "$@"
