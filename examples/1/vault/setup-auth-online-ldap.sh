#!/usr/bin/env bash
set -e
#set -x

#VAULT_TOKEN="$(consul kv get vault-root-token)"
#export VAULT_TOKEN

vault audit enable file file_path=audit.log 

vault auth enable ldap

vault write auth/ldap/config \
    url="ldap://ldap.forumsys.com" \
    binddn="cn=read-only-admin,dc=example,dc=com" \
    userdn="dc=example,dc=com" \
    groupdn="dc=example,dc=com" \
    userattr=uid

cat > scientists-policy.hcl <<-EOF
path "sys/mounts" {
    capabilities = ["read", "list"]
}
EOF

cat > mathematicians-policy.hcl <<-EOF
path "sys/mounts" {
    capabilities = ["read", "list"]
}
EOF

vault write sys/policy/scientists-policy policy=@scientists-policy.hcl
vault write sys/policy/mathematicians-policy policy=@mathematicians-policy.hcl

vault write auth/ldap/groups/scientists policies=default,scientists-policy
vault write auth/ldap/groups/mathematicians policies=default,mathematicians-policy

vault login -method=ldap username=einstein password=password
vault login -method=ldap username=newton password=password
vault login -method=ldap username=galieleo password=password
vault login -method=ldap username=tesla password=password

vault login -method=ldap username=riemann password=password
vault login -method=ldap username=gauss password=password
vault login -method=ldap username=euler password=password
vault login -method=ldap username=euclid password=password
