#!/usr/bin/env bash
set -e
#set -x

BOOTSTRAP_EXPECT="1"
RETRY_JOIN="11"

/vagrant/bin/configure-dnsmasq.sh
/vagrant/bin/install-app.sh consul
/vagrant/bin/install-app.sh vault

/vagrant/bin/configure-consul-server.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN}
/vagrant/bin/configure-vault-server.sh
/vagrant/bin/start-app.sh consul
/vagrant/bin/start-app.sh vault

sleep 5

/vagrant/bin/unseal-vault.sh
