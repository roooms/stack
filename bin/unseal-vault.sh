#!/usr/bin/env bash
set -e
#set -x

# shellcheck disable=SC1091
source /etc/profile.d/vault.sh

if [ ! "$(consul kv get vault-root-token)" ]; then 
  # no root token in consul kv so init vault
  echo "--> Initialising vault"
  vault operator init -key-shares=1 -key-threshold=1 | tee /tmp/vault.init
  KEY="$(grep '^Unseal' /tmp/vault.init | awk '{print $4}')" && \
    consul kv put vault-unseal-key "${KEY}"
  ROOT_TOKEN="$(grep '^Initial' /tmp/vault.init | awk '{print $4}')" && \
    consul kv put vault-root-token "${ROOT_TOKEN}"
  shred /tmp/vault.init
fi

echo "--> Unsealing vault"
vault operator unseal "$(consul kv get vault-unseal-key)"
