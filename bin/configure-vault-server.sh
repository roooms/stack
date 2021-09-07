#!/usr/bin/env bash
set -e
#set -x

VAULT_IP="$(hostname -I | awk '{print $2}')"
VAULT_ADDR="http://${VAULT_IP}:8200"
VAULT_STORAGE="${1:-"consul"}"
PLUGIN_DIR="/etc/vault.d/plugins"

echo "--> Enable mlock syscall for vault"
sudo setcap cap_ipc_lock=+ep /usr/local/bin/vault

echo "--> Configuring vault server"
sudo mkdir -p ${PLUGIN_DIR} && sudo chmod 755 ${PLUGIN_DIR}
# vault configuration file
sed -e "s/{{ vault_ip }}/${VAULT_IP}/g" \
    /vagrant/etc/vault.d/vault.hcl | sudo tee /etc/vault.d/vault.hcl
cat /vagrant/etc/vault.d/storage-${VAULT_STORAGE}.hcl | sudo tee /etc/vault.d/storage.hcl
# env configuration
echo "export VAULT_ADDR=${VAULT_ADDR}" | sudo tee /etc/profile.d/vault.sh
sudo chmod 644 /etc/profile.d/vault.sh
