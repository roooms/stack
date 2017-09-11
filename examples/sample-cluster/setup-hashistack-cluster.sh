#!/usr/bin/env bash
set -e
#set -x

SCRIPT_PATH="../../$(dirname ${BASH_SOURCE[0]})"

BOOTSTRAP_EXPECT="3"
DATACENTER="primary"
NODE_NAME="$(hostname)"
RETRY_JOIN="11"

bash ${SCRIPT_PATH}/bootstrap.sh
bash ${SCRIPT_PATH}/install-app.sh consul 0.9.2 consul-enterprise_0.9.2+ent_linux_amd64.zip
bash ${SCRIPT_PATH}/install-app.sh nomad 0.6.2
bash ${SCRIPT_PATH}/install-app.sh vault 0.8.2 vault-enterprise_0.8.2_linux_amd64.zip

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
