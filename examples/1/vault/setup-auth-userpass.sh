#!/usr/bin/env bash
set -e
#set -x

# shellcheck disable=SC1091
source /etc/profile.d/vault.sh

VAULT_TOKEN="$(consul kv get vault-root-token)"
export VAULT_TOKEN

vault policy write admin /vagrant/vault-policies/admin.hcl
vault policy write ops-team-user /vagrant/vault-policies/ops-team-user.hcl
vault policy write dev-team-user /vagrant/vault-policies/dev-team-user.hcl

vault auth enable userpass

vault write auth/userpass/users/admin \
  password=password \
  policies=admin

vault write auth/userpass/users/alice \
  password=password \
  policies=ops-team-user

vault write auth/userpass/users/brian \
  password=password \
  policies=ops-team-user

vault write auth/userpass/users/chris \
  password=password \
  policies=ops-team-user

vault write auth/userpass/users/donna \
  password=password \
  policies=dev-team-user
