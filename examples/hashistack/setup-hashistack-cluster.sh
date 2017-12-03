#!/usr/bin/env bash
set -e
#set -x

BOOTSTRAP_EXPECT="3"
NODE_NAME="$(hostname)"
RETRY_JOIN="11"

/vagrant/bin/configure-dnsmasq.sh
/vagrant/bin/install-app.sh consul 1.0.1 consul-enterprise_1.0.1+ent_linux_amd64.zip
/vagrant/bin/install-app.sh nomad 0.7.0 nomad-enterprise_0.7.0+ent_linux_amd64.zip
/vagrant/bin/install-app.sh vault 0.9.0

case ${NODE_NAME} in
  node1 | node2 | node3 )
    /vagrant/bin/configure-consul-server.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN}
    /vagrant/bin/configure-nomad-server.sh ${BOOTSTRAP_EXPECT}
    /vagrant/bin/configure-vault-server.sh
    /vagrant/bin/start-app.sh consul
    /vagrant/bin/start-app.sh nomad
    /vagrant/bin/start-app.sh vault
  ;;
  * )
    /vagrant/bin/configure-consul-client.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN}
    /vagrant/bin/configure-nomad-client.sh ${BOOTSTRAP_EXPECT}
    /vagrant/bin/start-app.sh consul
    /vagrant/bin/start-app.sh nomad
  ;;
esac
