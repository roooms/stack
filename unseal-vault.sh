#!/usr/bin/env bash
set -e
#set -x

cget() { consul kv get vault/${1}; }
cput() { consul kv put vault/${1} ${2}; }

source /etc/profile.d/vault.sh

if [ ! "$(cget root-token)" ]; then # no root token in consul kv so init vault
  echo "--> Initialising vault"
  vault init | tee /tmp/vault.init
  # store master keys in consul for operator to retrieve and remove
  COUNTER=1
  grep '^Unseal' /tmp/vault.init | awk '{print $4}' | for KEY in $(cat -); do
    cput unseal-key-${COUNTER} ${KEY}
    COUNTER="$((COUNTER + 1))"
  done
  # export root token and store in consul kv
  ROOT_TOKEN="$(cat /tmp/vault.init | grep '^Initial' | awk '{print $4}')" && \
  export ROOT_TOKEN
  cput root-token ${ROOT_TOKEN}
  # shred the output
  shred /tmp/vault.init
fi

# unseal vault
echo "--> Unsealing vault"
vault unseal "$(cget unseal-key-1)"
vault unseal "$(cget unseal-key-2)"
vault unseal "$(cget unseal-key-3)"
