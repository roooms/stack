#!/usr/bin/env bash
set -e
#set -x

# shellcheck disable=SC1091
source /etc/profile.d/vault.sh

if [[ -f ~/.vault-root-token ]]; then
  echo "--> Unsealing vault"
  vault operator unseal "$(cat ~/.vault-unseal-key)"
else
  echo "--> Initialising vault"
  vault operator init -key-shares=1 -key-threshold=1 | tee /tmp/vault.init
  KEY="$(grep '^Unseal' /tmp/vault.init | awk '{print $4}')" && \
    echo "${KEY}" > ~/.vault-unseal-key
  ROOT_TOKEN="$(grep '^Initial' /tmp/vault.init | awk '{print $4}')" && \
    echo "${ROOT_TOKEN}" > ~/.vault-root-token
  shred /tmp/vault.init
  echo "--> Unsealing vault"
  vault operator unseal "$(cat ~/.vault-unseal-key)"
fi
