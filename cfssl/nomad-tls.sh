#!/usr/bin/env bash
set -e
#set -x

# Install tools to generate certs and keys
if [[ ! -f $(command -v cfssl) ]]; then
  for bin in cfssl cfssl-certinfo cfssljson
  do
    echo "--> Installing $bin"
    curl -sSL https://pkg.cfssl.org/R1.2/${bin}_linux-amd64 > /tmp/${bin}
    sudo install /tmp/${bin} /usr/local/bin/${bin}
  done
fi

# Generate the CA's private key and certificate
cfssl print-defaults csr | cfssl gencert -initca - | cfssljson -bare nomad-ca

# Generate a certificate for the Nomad server
echo '{}' | cfssl gencert -ca=nomad-ca.pem -ca-key=nomad-ca-key.pem -config=cfssl.json \
  -hostname="server.global.nomad,localhost,127.0.0.1" - | cfssljson -bare nomad-server

# Generate a certificate for the Nomad client
echo '{}' | cfssl gencert -ca=nomad-ca.pem -ca-key=nomad-ca-key.pem -config=cfssl.json \
  -hostname="client.global.nomad,localhost,127.0.0.1" - | cfssljson -bare nomad-client

# Generate a certificate for the CLI
echo '{}' | cfssl gencert -ca=nomad-ca.pem -ca-key=nomad-ca-key.pem -profile=client \
  - | cfssljson -bare nomad-cli
