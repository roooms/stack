#!/usr/bin/env bash
set -e
#set -x

VAULT_TOKEN="$(consul kv get vault-root-token)"
export VAULT_TOKEN

vault mount consul
