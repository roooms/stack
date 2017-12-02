#!/usr/bin/env bash
set -e
#set -x

ADVERTISE_ADDR="$(hostname -I | awk '{print $2}')"
DATACENTER="${2:-"dc1"}"
BOOTSTRAP_EXPECT="${1:-"3"}"
NODE_NAME="$(hostname)"

echo "--> Configuring nomad server"
sed -e "s/0/${BOOTSTRAP_EXPECT}/g" \
    /vagrant/etc/nomad.d/server.hcl | sudo tee /etc/nomad.d/server.hcl
sed -e "s/{{ advertise_addr }}/${ADVERTISE_ADDR}/g" \
    -e "s/{{ datacenter }}/${DATACENTER}/g" \
    -e "s/{{ node_name }}/${NODE_NAME}/g" \
    /vagrant/etc/nomad.d/default.hcl | sudo tee /etc/nomad.d/default.hcl
