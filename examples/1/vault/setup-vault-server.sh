#!/usr/bin/env bash
set -e
#set -x

BOOTSTRAP_EXPECT="1"
RETRY_JOIN="11"

/vagrant/bin/configure-dnsmasq.sh
/vagrant/bin/install-app.sh consul 1.1.0 consul-enterprise_1.1.0_linux_amd64.zip
/vagrant/bin/install-app.sh consul-template 0.19.4
/vagrant/bin/install-app.sh vault 0.10.1 vault-enterprise_0.10.1+prem_linux_amd64.zip

/vagrant/bin/configure-consul-server.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN}
/vagrant/bin/configure-vault-server.sh
/vagrant/bin/start-app.sh consul
/vagrant/bin/start-app.sh vault
