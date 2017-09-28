#!/usr/bin/env bash
set -e
#set -x

SCRIPT_PATH="/vagrant/bin"

NODE_NAME="$(hostname)"

bash ${SCRIPT_PATH}/install-app.sh vault 0.8.2 vault-enterprise_0.8.2_linux_amd64.zip
bash ${SCRIPT_PATH}/configure-vault-server.sh
bash ${SCRIPT_PATH}/start-app.sh vault
echo "--> Sleep 10"
sleep 10

case ${NODE_NAME} in
  node1 | node4 )
    bash ${SCRIPT_PATH}/unseal-vault.sh
  ;;
  * )
    echo "--> Sleep 10 as another node might need to vault init"
    sleep 10
    bash ${SCRIPT_PATH}/unseal-vault.sh
  ;;
esac
