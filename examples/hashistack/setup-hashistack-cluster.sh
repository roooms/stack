#!/usr/bin/env bash
set -e
#set -x

SCRIPT_PATH="/vagrant/bin"

BOOTSTRAP_EXPECT="3"
DATACENTER="vagrant"
NODE_NAME="$(hostname)"
RETRY_JOIN="11"

bash ${SCRIPT_PATH}/configure-dnsmasq.sh
bash ${SCRIPT_PATH}/install-app.sh consul 0.6.4
bash ${SCRIPT_PATH}/install-app.sh nomad 0.6.3
bash ${SCRIPT_PATH}/install-app.sh vault 0.5.2 

case ${NODE_NAME} in
  node1 | node2 | node3 )
    bash ${SCRIPT_PATH}/configure-consul-server.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN} ${DATACENTER}
    bash ${SCRIPT_PATH}/configure-nomad-server.sh ${BOOTSTRAP_EXPECT} ${DATACENTER}
    bash ${SCRIPT_PATH}/configure-vault-server.sh
    bash ${SCRIPT_PATH}/start-app.sh consul
    bash ${SCRIPT_PATH}/start-app.sh nomad
    bash ${SCRIPT_PATH}/start-app.sh vault
  ;;
  * )
    bash ${SCRIPT_PATH}/configure-consul-client.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN} ${DATACENTER}
    bash ${SCRIPT_PATH}/configure-nomad-client.sh ${BOOTSTRAP_EXPECT} ${DATACENTER}
    bash ${SCRIPT_PATH}/start-app.sh consul
    bash ${SCRIPT_PATH}/start-app.sh nomad
  ;;
esac
