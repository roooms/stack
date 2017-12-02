#!/usr/bin/env bash
set -e
#set -x

BOOTSTRAP_EXPECT="3"
NODE_NAME="$(hostname)"
RETRY_JOIN="11"

/vagrant/bin/configure-dnsmasq.sh
/vagrant/bin/install-app.sh consul 1.0.1
/vagrant/bin/install-app.sh nomad 0.7.0

case ${NODE_NAME} in
  node1 | node2 | node3 )
    /vagrant/bin/configure-consul-server.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN}
    /vagrant/bin/configure-nomad-server.sh ${BOOTSTRAP_EXPECT}
    sudo cp /vagrant/etc/nomad.d/acl.hcl /etc/nomad.d/acl.hcl
    sudo cp /vagrant/etc/nomad.d/debug.hcl /etc/nomad.d/debug.hcl
    /vagrant/bin/start-app.sh consul
    /vagrant/bin/start-app.sh nomad
  ;;
  * )
    /vagrant/bin/configure-consul-client.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN}
    /vagrant/bin/configure-nomad-client.sh ${BOOTSTRAP_EXPECT}
    sudo cp /vagrant/etc/nomad.d/acl.hcl /etc/nomad.d/acl.hcl
    sudo cp /vagrant/etc/nomad.d/debug.hcl /etc/nomad.d/debug.hcl
    /vagrant/bin/start-app.sh consul
    /vagrant/bin/start-app.sh nomad
  ;;
esac
