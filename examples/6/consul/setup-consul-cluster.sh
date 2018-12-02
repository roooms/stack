#!/usr/bin/env bash
set -e
#set -x

BOOTSTRAP_EXPECT="${1:-"3"}"
NODE_NAME="$(hostname)"
RETRY_JOIN="${2:-"10.0.0.11"}"
DATACENTER="${3:-"dc1"}"
ACL_DATACENTER="${4:-$DATACENTER}"

/vagrant/bin/configure-dnsmasq.sh
/vagrant/bin/install-app.sh consul 1.2.2
/vagrant/bin/install-app.sh consul-esm 0.3.0
/vagrant/bin/install-app.sh consul-template 0.19.5

case ${NODE_NAME} in
  server* )
    /vagrant/bin/configure-consul-server.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN} ${DATACENTER} ${ACL_DATACENTER}
    /vagrant/bin/configure-consul-esm.sh
    /vagrant/bin/start-app.sh consul
  ;;
  * )
    /vagrant/bin/configure-consul-client.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN} ${DATACENTER} ${ACL_DATACENTER}
    /vagrant/bin/start-app.sh consul
  ;;
esac
