#!/usr/bin/env bash
set -e
#set -x

# shellcheck disable=SC1091
source /etc/profile.d/vault.sh

VAULT_TOKEN="$(consul kv get vault-root-token)"
export VAULT_TOKEN

vault kv put secret/token word=hashicorp
