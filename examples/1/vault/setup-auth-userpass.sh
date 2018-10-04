#!/usr/bin/env bash
set -e
#set -x

# shellcheck disable=SC1091
source /etc/profile.d/vault.sh

VAULT_TOKEN="$(consul kv get vault-root-token)"
export VAULT_TOKEN

vault write sys/policy/admin policy=@/vagrant/vault-policies/admin.hcl
vault write sys/policy/read-only policy=@/vagrant/vault-policies/read-only.hcl
vault write sys/policy/app1 policy=@/vagrant/vault-policies/app1.hcl
vault write sys/policy/app2 policy=@/vagrant/vault-policies/app2.hcl

vault auth enable userpass

vault write auth/userpass/users/alice \
  password=password \
  policies=admin

vault write auth/userpass/users/brian \
  password=password \
  policies=read-only

vault write auth/userpass/users/chris \
  password=password \
  policies=app1

vault write auth/userpass/users/donna \
  password=password \
  policies=app2
