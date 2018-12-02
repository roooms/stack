#!/usr/bin/env bash
set -e
#set -x

## ----------------------------------------------------------------------------
## Needs some work due to node renaming from node[1-6] to server and client
## ----------------------------------------------------------------------------

NODE_NAME="$(hostname)"

/vagrant/bin/install-app.sh consul 1.2.2 consul-enterprise_1.2.2+prem_linux_amd64.zip
/vagrant/bin/install-app.sh consul-replicate

case ${NODE_NAME} in
  server* )
    BOOTSTRAP_EXPECT="3"
    DATACENTER="north"
    RETRY_JOIN="10.0.0.11"
    /vagrant/bin/configure-consul-server.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN} ${DATACENTER} ${ACL_DATACENTER}
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
    RETRY_JOIN="10.0.0.14"
    /vagrant/bin/configure-consul-server.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN} ${DATACENTER} ${ACL_DATACENTER}
    /vagrant/bin/start-app.sh consul
    echo "--> Sleep 10"
    sleep 10
    echo "--> Join LAN peer"
    sudo consul join 10.0.0.14
    echo "--> Join WAN peer"
    sudo consul join -wan 10.0.0.11
  ;;
esac
