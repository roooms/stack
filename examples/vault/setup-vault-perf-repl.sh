#!/usr/bin/env bash
set -e
#set -x

SCRIPT_PATH="/vagrant/bin"

NODE_NAME="$(hostname)"

/vagrant/bin/install-app.sh consul 1.0.1 consul-enterprise_1.0.1+ent_linux_amd64.zip

case ${NODE_NAME} in
  node1 | node2 | node3 )
    BOOTSTRAP_EXPECT="3"
    DATACENTER="north"
    RETRY_JOIN="11"
    /vagrant/bin/configure-consul-server.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN} ${DATACENTER}
    /vagrant/bin/start-app.sh consul
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
    /vagrant/bin/configure-consul-server.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN} ${DATACENTER}
    /vagrant/bin/start-app.sh consul
    echo "--> Sleep 10"
    sleep 10
    echo "--> Join LAN peer"
    sudo consul join 10.0.0.14
    echo "--> Join WAN peer"
    sudo consul join -wan 10.0.0.11
  ;;
esac

/vagrant/bin/install-app.sh vault 0.8.3 vault-enterprise_0.8.3_linux_amd64.zip
/vagrant/bin/configure-vault-server.sh
/vagrant/bin/start-app.sh vault
echo "--> Sleep 10"
sleep 10

case ${NODE_NAME} in
  node1 | node4 )
    /vagrant/bin/unseal-vault.sh
  ;;
  * )
    echo "--> Sleep 10 as another node might need to vault init"
    sleep 10
    /vagrant/bin/unseal-vault.sh
  ;;
esac
