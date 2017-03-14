#!/usr/bin/env bash
set -ex

cget() { consul kv get vault/${1} }
cput() { consul kv put vault/${1} ${2} }

if [ ! $(cget root-token) ]; then # no root token in consul kv so init vault
  vault init | tee /tmp/vault.init > /dev/null
  # store master keys in consul for operator to retrieve and remove
  COUNTER=1
  grep '^Unseal' /tmp/vault.init | awk '{print $4}' | for KEY in $(cat -); do
    cput unseal-key-${COUNTER} ${KEY}
    COUNTER="$((COUNTER + 1))"
  done
  # export root token and store in consul kv
  export ROOT_TOKEN="$(cat /tmp/vault.init | grep '^Initial' | awk '{print $4}')"
  cput vault/root-token ${ROOT_TOKEN}
  # shred the output
  shred /tmp/vault.init
fi

# unseal vault
vault unseal $(cget unseal-key-1)
vault unseal $(cget unseal-key-2)
vault unseal $(cget unseal-key-3)
