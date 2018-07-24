#!/usr/bin/env bash
set -e
#set -x

BOOTSTRAP_EXPECT="3"
NODE_NAME="$(hostname)"
RETRY_JOIN="11"

/vagrant/bin/configure-dnsmasq.sh
/vagrant/bin/install-app.sh consul 1.1.0 consul-enterprise_1.1.0_linux_amd64.zip
/vagrant/bin/install-app.sh consul-template 0.19.4
/vagrant/bin/install-app.sh nomad 0.8.0
/vagrant/bin/install-app.sh vault 0.10.1 vault-enterprise_0.10.1+prem_linux_amd64.zip

case "${NODE_NAME}" in
  node1 | node2 | node3 )
    /vagrant/bin/configure-consul-server.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN}
    /vagrant/bin/configure-nomad-server.sh ${BOOTSTRAP_EXPECT}
    /vagrant/bin/configure-vault-server.sh
    /vagrant/bin/start-app.sh consul
    /vagrant/bin/start-app.sh nomad
    /vagrant/bin/start-app.sh vault
  ;;
  * )
  ;;
esac

case ${NODE_NAME} in
  node1 )
    sleep 8
    /vagrant/bin/vault-unseal.sh
  ;;
  node2 | node3 )
    sleep 16
    /vagrant/bin/vault-unseal.sh
  ;;
  * )
  ;;
esac
