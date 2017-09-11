#!/usr/bin/env bash
set -e
#set -x

SCRIPT_PATH="$(dirname ${BASH_SOURCE[0]})"

NODE_NAME="$(hostname)"

#bash ${SCRIPT_PATH}/bootstrap.sh
bash ${SCRIPT_PATH}/install-app.sh consul 0.9.2 consul-enterprise_0.9.2+ent_linux_amd64.zip
bash ${SCRIPT_PATH}/install-app.sh nomad 0.6.2
bash ${SCRIPT_PATH}/install-app.sh vault 0.8.2 vault-enterprise_0.8.2_linux_amd64.zip

case ${NODE_NAME} in
  node1 | node2 | node3 )
    BOOTSTRAP_EXPECT="3"
    DATACENTER="north"
    RETRY_JOIN="11"
    bash ${SCRIPT_PATH}/configure-consul-server.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN} ${DATACENTER}
    bash ${SCRIPT_PATH}/start-app.sh consul
    echo "--> Sleep 10 while consul gets ready"
    sleep 10
    sudo consul join 10.0.0.${RETRY_JOIN}
    bash ${SCRIPT_PATH}/configure-vault-server.sh
    bash ${SCRIPT_PATH}/start-app.sh vault
    echo "--> WAN connect clusters"
    sudo consul join -wan 10.0.0.14
  ;;
  * )
    BOOTSTRAP_EXPECT="3"
    DATACENTER="south"
    RETRY_JOIN="14"
    bash ${SCRIPT_PATH}/configure-consul-server.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN} ${DATACENTER}
    bash ${SCRIPT_PATH}/start-app.sh consul
    echo "--> Sleep 10 while consul gets ready"
    sleep 10
    sudo consul join 10.0.0.${RETRY_JOIN}
    bash ${SCRIPT_PATH}/configure-vault-server.sh
    bash ${SCRIPT_PATH}/start-app.sh vault
    echo "--> WAN connect clusters"
    sudo consul join -wan 10.0.0.11
  ;;
esac

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
