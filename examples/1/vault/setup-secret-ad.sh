#!/usr/bin/env bash
set -e
#set -x

# install LDAP
#sudo apt install slapd ldap-utils libnss-ldap ldapscripts
#sudo dpkg-reconfigure slapd
#vim add_content.ldif
#ldapadd -x -D cn=admin,dc=example,dc=com -W -f add_content.ldif
#ldapsearch -x -LLL -b dc=example,dc=com 'uid=john' cn gidNumber
#cat /etc/ldap.conf
#sudo auth-client-config -t nss -p lac_ldap
#sudo pam-auth-update

# shellcheck disable=SC1091
source /etc/profile.d/vault.sh

VAULT_TOKEN="$(consul kv get vault-root-token)"
export VAULT_TOKEN

vault secrets enable ad
