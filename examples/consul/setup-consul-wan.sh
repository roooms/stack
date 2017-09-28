#!/usr/bin/env bash
set -e
#set -x

SCRIPT_PATH="/vagrant/bin"

NODE_NAME="$(hostname)"

bash ${SCRIPT_PATH}/install-app.sh consul 0.9.2 consul-enterprise_0.9.2+ent_linux_amd64.zip

case ${NODE_NAME} in
  node1 | node2 | node3 )
    BOOTSTRAP_EXPECT="3"
    DATACENTER="north"
    RETRY_JOIN="11"
    bash ${SCRIPT_PATH}/configure-consul-server.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN} ${DATACENTER}
    bash ${SCRIPT_PATH}/start-app.sh consul
    echo "--> Sleep 10"
    sleep 10
    echo "--> Join LAN peer"
    sudo consul join 10.0.0.11
    echo "--> Join WAN peer"
    sudo consul join -wan 10.0.0.14
  ;;
  * )
    BOOTSTRAP_EXPECT="3"
    DATACENTER="south"
    RETRY_JOIN="14"
    bash ${SCRIPT_PATH}/configure-consul-server.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN} ${DATACENTER}
    bash ${SCRIPT_PATH}/start-app.sh consul
    echo "--> Sleep 10"
    sleep 10
    echo "--> Join LAN peer"
    sudo consul join 10.0.0.14
    echo "--> Join WAN peer"
    sudo consul join -wan 10.0.0.11
  ;;
esac
