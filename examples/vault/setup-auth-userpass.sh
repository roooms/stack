#!/usr/bin/env bash
set -e
#set -x

VAULT_TOKEN="$(consul kv get vault-root-token)"
export VAULT_TOKEN

vault write sys/policy/admin rules=@/vagrant/vault-policies/admin.hcl
vault write sys/policy/reader rules=@/vagrant/vault-policies/reader.hcl
vault write sys/policy/writer rules=@/vagrant/vault-policies/writer.hcl

vault auth-enable userpass

vault write auth/userpass/users/alice \
  password=password \
  policies=admin

vault write auth/userpass/users/brian \
  password=password \
  policies=reader

vault write auth/userpass/users/chris \
  password=password \
  policies=writer
