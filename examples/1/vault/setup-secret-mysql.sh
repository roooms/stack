#!/usr/bin/env bash
set -e
#set -x

# shellcheck disable=SC1091
source /etc/profile.d/vault.sh

VAULT_TOKEN="$(consul kv get vault-root-token)"
export VAULT_TOKEN

# Install mysql
sudo debconf-set-selections <<< 'mysql-server-5.7 mysql-server/root_password password R00t?'
sudo debconf-set-selections <<< 'mysql-server-5.7 mysql-server/root_password_again password R00t?'
sudo apt-get update --fix-missing
sudo apt-get install mysql-server-5.7 --yes

# Configure mysql for vault administration
sleep 2
mysql -u root -p'R00t?' << EOF
GRANT ALL PRIVILEGES ON *.* TO 'vaultadmin'@'127.0.0.1' IDENTIFIED BY 'vaultadminpassword' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

# Enable database secrets engine
sleep 2
vault secrets enable database


# Configure mysql connection
sleep 2
vault write database/config/mysql \
    plugin_name=mysql-database-plugin \
    connection_url="vaultadmin:vaultadminpassword@tcp(127.0.0.1:3306)/" \
    allowed_roles="readonly"

# Create MySQL readonly role
sleep 2
vault write database/roles/readonly \
    db_name=mysql \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT SELECT ON *.* TO '{{name}}'@'%';" \
    default_ttl="1m" \
    max_ttl="24h"

# Read a set of credentials from the role
sleep 2
vault read database/creds/readonly

# Check the user is created
sleep 2
mysql -u root -p'R00t?' -e "select user from mysql.user;"
#watch -d "mysql -u root -p'r00t' -e 'select user from mysql.user;'"
