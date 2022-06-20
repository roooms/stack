#!/usr/bin/env bash
set -e
#set -x

BOOTSTRAP_EXPECT="${1:-"3"}"
NODE_NAME="$(hostname)"
RETRY_JOIN="${2:-"192.168.56.11"}"
DATACENTER="${3:-"dc1"}"
ACL_DATACENTER="${4:-$DATACENTER}"

/vagrant/bin/configure-dnsmasq.sh
/vagrant/bin/install-app-pkg.sh consul

case ${NODE_NAME} in
  server* )
    /vagrant/bin/configure-consul-server.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN} ${DATACENTER} ${ACL_DATACENTER}
    /vagrant/bin/start-app.sh consul
  ;;
  * )
    /vagrant/bin/configure-consul-client.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN} ${DATACENTER} ${ACL_DATACENTER}
    /vagrant/bin/start-app.sh consul
  ;;
esac
