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
  server* )
    /vagrant/bin/configure-consul-server.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN}
    /vagrant/bin/start-app.sh consul
    /vagrant/bin/configure-vault-server.sh
    /vagrant/bin/start-app.sh vault
  ;;
  * )
    /vagrant/bin/configure-consul-client.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN}
    /vagrant/bin/start-app.sh consul
  ;;
esac

case ${NODE_NAME} in
  server1 )
    sleep 8
    /vagrant/bin/unseal-vault.sh
  ;;
  server2 | server3 )
    sleep 16
    /vagrant/bin/unseal-vault.sh
  ;;
  * )
  ;;
esac
