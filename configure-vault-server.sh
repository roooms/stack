#!/usr/bin/env bash
set -e
#set -x

SCRIPT_PATH="$(dirname ${BASH_SOURCE[0]})"
VAULT_IP="$(ip route | grep "enp0s8" | awk '{print $9}')"
VAULT_ADDR="http://${VAULT_IP}:8200"

echo "--> Configuring vault server"
# vault configuration file
sed -e "s/{{ vault_ip }}/${VAULT_IP}/g" \
    ${SCRIPT_PATH}/config/etc_vault.d_default.hcl \
    | sudo tee /etc/vault.d/default.hcl
# env configuration
echo "export VAULT_ADDR=${VAULT_ADDR}" | sudo tee /etc/profile.d/vault.sh
sudo chmod 644 /etc/profile.d/vault.sh
