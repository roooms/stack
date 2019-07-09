#!/usr/bin/env bash
set -e
#set -x

# LDAP Server Information (read-only access):
# Server: ldap.forumsys.com  
# Port: 389
# Bind DN: cn=read-only-admin,dc=example,dc=com
# Bind Password: password
# 
# All user passwords are password.
# You may also bind to individual Users (uid) or the two Groups (ou) that include:
# 
# ou=mathematicians,dc=example,dc=com
# riemann
# gauss
# euler
# euclid
# 
# ou=scientists,dc=example,dc=com
# einstein
# newton
# galieleo
# tesla

vault audit enable file file_path=/tmp/vault-audit.log 

# Create policies in Vault
vault policy write newton-entity newton-entity.hcl # entity policy
vault policy write newton-ldap newton-ldap.hcl # ldap user policy
vault policy write scientists scientists.hcl # ldap group policy
vault policy write newton-userpass newton-userpass.hcl # userpass user policy

# Enable and configure ldap auth method
vault auth enable ldap
vault auth list -format=json | jq -r '.["ldap/"].accessor' | tee /tmp/ldap_accessor.txt
vault write auth/ldap/config \
    url="ldap://ldap.forumsys.com" \
    binddn="cn=read-only-admin,dc=example,dc=com" \
    userdn="dc=example,dc=com" \
    groupdn="dc=example,dc=com" \
    userattr=uid

# Attach policies to ldap user and ldap group
vault write auth/ldap/users/newton policies=newton-ldap
vault write auth/ldap/groups/scientists policies=scientists

# Enable and configure userpass auth method
vault auth enable userpass
vault auth list -format=json | jq -r '.["userpass/"].accessor' | tee /tmp/userpass_accessor.txt

# Create newton userpass user and attach userpass user policy
vault write auth/userpass/users/newton password="password" policies="newton-userpass"

# Create entity
vault write identity/entity name="isaac-newton" policies="newton-entity"
vault read -field=id /identity/entity/name/isaac-newton | tee /tmp/isaac-newton_id.txt

# Create entity alias for ldap user
vault write identity/entity-alias name="newton" \
    canonical_id=$(cat /tmp/isaac-newton_id.txt) \
    mount_accessor=$(cat /tmp/ldap_accessor.txt)

# Create entity alias for userpass user
vault write identity/entity-alias name="newton" \
    canonical_id=$(cat /tmp/isaac-newton_id.txt) \
    mount_accessor=$(cat /tmp/userpass_accessor.txt)
