#!/usr/bin/env bash
set -e
#set -x

BOOTSTRAP_EXPECT="${1:-"3"}"
NODE_NAME="$(hostname)"
RETRY_JOIN="${2:-"10.0.0.11"}"

/vagrant/bin/configure-dnsmasq.sh
/vagrant/bin/install-app.sh consul
/vagrant/bin/install-app.sh consul-template

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
  server* )
    /vagrant/bin/configure-consul-server.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN}
    configure_tls consul server
    /vagrant/bin/start-app.sh consul
  ;;
  * )
    /vagrant/bin/configure-consul-client.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN}
    configure_tls consul client
    /vagrant/bin/start-app.sh consul
  ;;
esac

export CONSUL_HTTP_ADDR="https://localhost:8500"
export CONSUL_CACERT="/etc/consul.d/tls/consul-ca.pem"
export CONSUL_CLIENT_CERT="/etc/consul.d/tls/consul-cli.pem"
export CONSUL_CLIENT_KEY="/etc/consul.d/tls/consul-cli-key.pem"

echo "export CONSUL_HTTP_ADDR=https://localhost:8500" | sudo tee -a /etc/profile.d/consul.sh
echo "export CONSUL_CACERT=/etc/consul.d/tls/consul-ca.pem" | sudo tee -a /etc/profile.d/consul.sh
echo "export CONSUL_CLIENT_CERT=/etc/consul.d/tls/consul-cli.pem" | sudo tee -a /etc/profile.d/consul.sh
echo "export CONSUL_CLIENT_KEY=/etc/consul.d/tls/consul-cli-key.pem" | sudo tee -a /etc/profile.d/consul.sh
sudo chmod 644 /etc/profile.d/consul.sh
