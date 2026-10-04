#!/bin/sh
# Private Docker registry: refuses to start without credentials, so it is never an anonymous
# file host on a public domain. The credentials are not REGISTRY_* variables: the registry reads
# every REGISTRY_* variable as a configuration key.
set -eu

if [ -z "${AUTH_USERNAME:-}" ] || [ -z "${AUTH_PASSWORD:-}" ]; then
  echo "AUTH_USERNAME and AUTH_PASSWORD must both be set: this registry does not run without authentication." >&2
  exit 1
fi

# bcrypt is the only hash the registry's htpasswd backend accepts
htpasswd -Bbc /tmp/htpasswd "$AUTH_USERNAME" "$AUTH_PASSWORD" 2>/dev/null

export REGISTRY_AUTH=htpasswd
export REGISTRY_AUTH_HTPASSWD_REALM="Registry"
export REGISTRY_AUTH_HTPASSWD_PATH=/tmp/htpasswd
export REGISTRY_HTTP_ADDR="0.0.0.0:${PORT:-5000}"
export REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY="${REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY:-/var/lib/registry}"
# Lets `docker image rm` on the server side free space after deleting tags through the API
export REGISTRY_STORAGE_DELETE_ENABLED="${REGISTRY_STORAGE_DELETE_ENABLED:-true}"

echo "Registry for user ${AUTH_USERNAME} on port ${PORT:-5000}"
exec /entrypoint.sh /etc/distribution/config.yml
