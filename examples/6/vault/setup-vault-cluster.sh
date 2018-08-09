#!/usr/bin/env bash
set -e
#set -x

BOOTSTRAP_EXPECT="3"
NODE_NAME="$(hostname)"
RETRY_JOIN="11"

/vagrant/bin/configure-dnsmasq.sh
/vagrant/bin/install-app.sh consul
/vagrant/bin/install-app.sh consul-template
/vagrant/bin/install-app.sh vault

case ${NODE_NAME} in
  node1 | node2 | node3 )
    /vagrant/bin/configure-consul-server.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN}
    /vagrant/bin/start-app.sh consul
  ;;
  * )
    /vagrant/bin/configure-consul-client.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN}
    /vagrant/bin/start-app.sh consul
    /vagrant/bin/configure-vault-server.sh
    /vagrant/bin/start-app.sh vault
  ;;
esac
