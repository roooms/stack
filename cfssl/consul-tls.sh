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
cfssl print-defaults csr | cfssl gencert -initca - | cfssljson -bare consul-ca

# Generate a certificate for the Consul server
echo '{"key":{"algo":"rsa","size":2048}}' | cfssl gencert -ca=consul-ca.pem -ca-key=consul-ca-key.pem -config=cfssl.json \
    -hostname="server.node.global.consul,localhost,127.0.0.1" - | cfssljson -bare consul-server

# Generate a certificate for the Consul client
echo '{"key":{"algo":"rsa","size":2048}}' | cfssl gencert -ca=consul-ca.pem -ca-key=consul-ca-key.pem -config=cfssl.json \
    -hostname="client.node.global.consul,localhost,127.0.0.1" - | cfssljson -bare consul-client

# Generate a certificate for the CLI
echo '{"key":{"algo":"rsa","size":2048}}' | cfssl gencert -ca=consul-ca.pem -ca-key=consul-ca-key.pem -profile=client \
    - | cfssljson -bare consul-cli
