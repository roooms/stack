#!/usr/bin/env bash
set -e
set -x

# shellcheck disable=SC1091
source /etc/profile.d/vault.sh

VAULT_TOKEN="$(consul kv get vault-root-token)"
export VAULT_TOKEN

# install admin policy and group
vault policy write admin /vagrant/vault-policies/admin.hcl
vault write identity/group name="admin" policies="admin" type="internal" 

# install team namespaces and policies
for team in mathematicians scientists; do
  vault namespace create ${team}
  vault policy write -ns="${team}" ${team} /vagrant/vault-policies/${team}.hcl
done

# enable ldap root-level auth method
vault auth enable ldap
vault write auth/ldap/config \
  url="ldap://ldap.forumsys.com" \
  binddn="cn=read-only-admin,dc=example,dc=com" \
  userdn="dc=example,dc=com" \
  groupdn="dc=example,dc=com" \
  userattr="uid"

# lookup ldap auth method accessor and tee to file
vault auth list -format="json" | jq -r '.["ldap/"].accessor' | tee ldap_accessor.txt

# create ldap-linked groups
vault write -format="json" identity/group name="mathematicians-root-group" policies="test" type="external" | jq -r ".data.id" | tee mathematicians_root_id.txt
vault write -format="json" identity/group name="scientists-root-group" policies="test" type="external" | jq -r ".data.id" | tee scientists_root_id.txt
# create root group-aliases
vault write -format="json" identity/group-alias name="mathematicians" canonical_id="$(cat mathematicians_root_id.txt)" mount_accessor="$(cat ldap_accessor.txt)"
vault write -format="json" identity/group-alias name="scientists" canonical_id="$(cat scientists_root_id.txt)" mount_accessor="$(cat ldap_accessor.txt)"
# create namespace group and add root group as a member
vault write -ns="mathematicians" identity/group name="mathematicians-ns-group" policies="mathematicians" type="internal" member_group_ids="$(cat mathematicians_root_id.txt)"
vault write -ns="scientists" identity/group name="scientists-ns-group" policies="scientists" type="internal" member_group_ids="$(cat scientists_root_id.txt)"

# create entities and aliases
for user in tesla gauss; do
  # create entities and tee entity id to file
  vault write -format="json" identity/entity name="${user}" | jq -r ".data.id" | tee ${user}_entity_id.txt
  # create entity aliases linking ldap user to entity id
  vault write identity/entity-alias name="${user}" canonical_id="$(cat ${user}_entity_id.txt)" mount_accessor="$(cat ldap_accessor.txt)"
done
