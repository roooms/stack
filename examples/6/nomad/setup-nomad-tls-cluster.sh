#!/usr/bin/env bash
set -e
#set -x

BOOTSTRAP_EXPECT="3"
NODE_NAME="$(hostname)"
RETRY_JOIN="11"

/vagrant/bin/configure-dnsmasq.sh
/vagrant/bin/install-app.sh consul 1.0.1 consul-enterprise_1.0.1+ent_linux_amd64.zip
/vagrant/bin/install-app.sh nomad 0.7.0 nomad-enterprise_0.7.0+ent_linux_amd64.zip

configure_tls() {
  APP="$1"
  AGENT_TYPE="$2"
  echo "--> Configuring ${APP} tls"
  sed -e "s/{{ agent_type }}/${AGENT_TYPE}/g" /vagrant/etc/${APP}.d/tls.hcl \
    | sudo tee /etc/${APP}.d/tls.hcl
  sudo mkdir --parents /etc/${APP}.d/tls/
  sudo cp /vagrant/etc/${APP}.d/tls/${APP}-ca.pem /etc/${APP}.d/tls/${APP}-ca.pem
  sudo cp /vagrant/etc/${APP}.d/tls/${APP}-${AGENT_TYPE}.pem /etc/${APP}.d/tls/${APP}-${AGENT_TYPE}.pem
  sudo cp /vagrant/etc/${APP}.d/tls/${APP}-${AGENT_TYPE}-key.pem /etc/${APP}.d/tls/${APP}-${AGENT_TYPE}-key.pem
  sudo cp /vagrant/etc/${APP}.d/tls/${APP}-cli.pem /etc/${APP}.d/tls/${APP}-cli.pem
  sudo cp /vagrant/etc/${APP}.d/tls/${APP}-cli-key.pem /etc/${APP}.d/tls/${APP}-cli-key.pem
  sudo chmod +r /etc/${APP}.d/tls/*
}

case ${NODE_NAME} in
  node1 | node2 | node3 )
    /vagrant/bin/configure-consul-server.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN}
    /vagrant/bin/configure-nomad-server.sh ${BOOTSTRAP_EXPECT}
    sudo cp /vagrant/etc/nomad.d/debug.hcl /etc/nomad.d/debug.hcl
    configure_tls nomad server
    /vagrant/bin/start-app.sh consul
    /vagrant/bin/start-app.sh nomad
  ;;
  * )
    /vagrant/bin/install-docker.sh
    /vagrant/bin/configure-consul-client.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN}
    /vagrant/bin/configure-nomad-client.sh ${BOOTSTRAP_EXPECT}
    sudo cp /vagrant/etc/nomad.d/debug.hcl /etc/nomad.d/debug.hcl
    configure_tls nomad client
    /vagrant/bin/start-app.sh consul
    /vagrant/bin/start-app.sh nomad
  ;;
esac

export NOMAD_ADDR="https://localhost:4646"
export NOMAD_CACERT="/etc/nomad.d/tls/nomad-ca.pem"
export NOMAD_CLIENT_CERT="/etc/nomad.d/tls/nomad-cli.pem"
export NOMAD_CLIENT_KEY="/etc/nomad.d/tls/nomad-cli-key.pem"

echo "export NOMAD_ADDR=https://localhost:4646" | sudo tee -a /etc/profile.d/nomad.sh
echo "export NOMAD_CACERT=/etc/nomad.d/tls/nomad-ca.pem" | sudo tee -a /etc/profile.d/nomad.sh
echo "export NOMAD_CLIENT_CERT=/etc/nomad.d/tls/nomad-cli.pem" | sudo tee -a /etc/profile.d/nomad.sh
echo "export NOMAD_CLIENT_KEY=/etc/nomad.d/tls/nomad-cli-key.pem" | sudo tee -a /etc/profile.d/nomad.sh
sudo chmod 644 /etc/profile.d/nomad.sh
