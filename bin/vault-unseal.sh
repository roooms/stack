#!/usr/bin/env bash
set -e
#set -x

cget() { consul kv get "${1}"; }
cput() { consul kv put "${1}" "${2}"; }

# shellcheck disable=SC1091
source /etc/profile.d/vault.sh

if [ ! "$(cget vault-root-token)" ]; then # no root token in consul kv so init vault
  echo "--> Initialising vault"
  vault operator init | tee /tmp/vault.init
  # store master keys in consul for operator to retrieve and remove
  COUNTER=1
  grep '^Unseal' /tmp/vault.init | awk '{print $4}' | for KEY in $(cat -); do
    cput vault-unseal-key-${COUNTER} "${KEY}"
    COUNTER="$((COUNTER + 1))"
  done
  # export root token and store in consul kv
  ROOT_TOKEN="$(grep '^Initial' /tmp/vault.init | awk '{print $4}')" && 
  cput vault-root-token "${ROOT_TOKEN}"
  # shred the output
  shred /tmp/vault.init
fi

# unseal vault
echo "--> Unsealing vault"
vault operator unseal "$(cget vault-unseal-key-1)"
vault operator unseal "$(cget vault-unseal-key-2)"
vault operator unseal "$(cget vault-unseal-key-3)"
