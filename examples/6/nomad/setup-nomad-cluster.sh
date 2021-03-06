#!/usr/bin/env bash
set -e
#set -x

BOOTSTRAP_EXPECT="${1:-"3"}"
NODE_NAME="$(hostname)"
RETRY_JOIN="${2:-"10.0.0.11"}"

/vagrant/bin/configure-dnsmasq.sh
/vagrant/bin/install-app.sh consul 1.2.2 consul-enterprise_1.2.2+prem_linux_amd64.zip
/vagrant/bin/install-app.sh nomad

case ${NODE_NAME} in
  server* )
    /vagrant/bin/configure-consul-server.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN}
    /vagrant/bin/configure-nomad-server.sh ${BOOTSTRAP_EXPECT}
    sudo cp /vagrant/etc/nomad.d/debug.hcl /etc/nomad.d/debug.hcl
    /vagrant/bin/start-app.sh consul
    /vagrant/bin/start-app.sh nomad
  ;;
  * )
    /vagrant/bin/install-docker.sh
    /vagrant/bin/configure-consul-client.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN}
    /vagrant/bin/configure-nomad-client.sh ${BOOTSTRAP_EXPECT}
    sudo cp /vagrant/etc/nomad.d/debug.hcl /etc/nomad.d/debug.hcl
    /vagrant/bin/start-app.sh consul
    /vagrant/bin/start-app.sh nomad
  ;;
esac
