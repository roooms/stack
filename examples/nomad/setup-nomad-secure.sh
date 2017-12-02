#!/usr/bin/env bash
set -e
#set -x

# Install tools to generate certs and keys
#for bin in cfssl cfssl-certinfo cfssljson
#do
#  echo "Installing $bin..."
#  curl -sSL https://pkg.cfssl.org/R1.2/${bin}_linux-amd64 > /tmp/${bin}
#  sudo install /tmp/${bin} /usr/local/bin/${bin}
#done

# Generate the CA's private key and certificate
#cfssl print-defaults csr | cfssl gencert -initca - | cfssljson -bare nomad-ca

# Generate a certificate for the Nomad server
#echo '{}' | cfssl gencert -ca=nomad-ca.pem -ca-key=nomad-ca-key.pem -config=cfssl.json \
#            -hostname="server.global.nomad,localhost,127.0.0.1" - | cfssljson -bare server

# Generate a certificate for the Nomad client
#echo '{}' | cfssl gencert -ca=nomad-ca.pem -ca-key=nomad-ca-key.pem -config=cfssl.json \
#            -hostname="client.global.nomad,localhost,127.0.0.1" - | cfssljson -bare client

# Generate a certificate for the CLI
#echo '{}' | cfssl gencert -ca=nomad-ca.pem -ca-key=nomad-ca-key.pem -profile=client \
#            - | cfssljson -bare cli

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
    sudo cp /vagrant/etc/nomad.d/debug.hcl /etc/nomad.d/debug.hcl
    echo "--> Configuring nomad server for tls"
    sed -e "s/{{ agent_type }}/server/g" /vagrant/etc/nomad.d/tls.hcl \
        | sudo tee /etc/nomad.d/tls.hcl
    sudo cp -R /vagrant/examples/nomad/tls /etc/nomad.d/
    sudo chmod +r /etc/nomad.d/tls/*
    /vagrant/bin/start-app.sh consul
    /vagrant/bin/start-app.sh nomad
  ;;
  * )
    /vagrant/bin/configure-consul-client.sh ${BOOTSTRAP_EXPECT} ${RETRY_JOIN}
    /vagrant/bin/configure-nomad-client.sh ${BOOTSTRAP_EXPECT}
    sudo cp /vagrant/etc/nomad.d/debug.hcl /etc/nomad.d/debug.hcl
    echo "--> Configuring nomad client for tls"
    sed -e "s/{{ agent_type }}/client/g" /vagrant/etc/nomad.d/tls.hcl \
        | sudo tee /etc/nomad.d/tls.hcl
    sudo cp -R /vagrant/examples/nomad/tls /etc/nomad.d/
    sudo chmod +r /etc/nomad.d/tls/*
    /vagrant/bin/start-app.sh consul
    /vagrant/bin/start-app.sh nomad
  ;;
esac

export NOMAD_ADDR="https://localhost:4646"
export NOMAD_CACERT="/etc/nomad.d/tls/nomad-ca.pem"
export NOMAD_CLIENT_CERT="/etc/nomad.d/tls/cli.pem"
export NOMAD_CLIENT_KEY="/etc/nomad.d/tls/cli-key.pem"

echo "export NOMAD_ADDR=https://localhost:4646" | sudo tee -a /etc/profile.d/nomad.sh
echo "export NOMAD_CACERT=/etc/nomad.d/tls/nomad-ca.pem" | sudo tee -a /etc/profile.d/nomad.sh
echo "export NOMAD_CLIENT_CERT=/etc/nomad.d/tls/cli.pem" | sudo tee -a /etc/profile.d/nomad.sh
echo "export NOMAD_CLIENT_KEY=/etc/nomad.d/tls/cli-key.pem" | sudo tee -a /etc/profile.d/nomad.sh
sudo chmod 644 /etc/profile.d/nomad.sh
