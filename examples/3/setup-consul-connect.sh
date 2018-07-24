#!/usr/bin/env bash
set -e
#set -x

BOOTSTRAP_EXPECT="1"
NODE_NAME="$(hostname)"
RETRY_JOIN="11"

/vagrant/bin/configure-dnsmasq.sh
/vagrant/bin/install-app.sh consul 1.2.0 consul_1.2.0-beta1_linux_amd64.zip
/vagrant/bin/install-app.sh consul-template 0.19.4

case "${NODE_NAME}" in
  node1 )
    /vagrant/bin/configure-consul-server.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN}
    sudo cp /vagrant/etc/consul.d/connect.hcl /etc/consul.d/connect.hcl
    /vagrant/bin/start-app.sh consul
  ;;
  * )
    /vagrant/bin/configure-consul-client.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN}
    /vagrant/bin/start-app.sh consul
  ;;
esac
