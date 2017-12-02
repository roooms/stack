#!/usr/bin/env bash
set -e
#set -x

ADVERTISE_ADDR="$(hostname -I | awk '{print $2}')"
NETWORK_INTERFACE="$(ip route | grep ${ADVERTISE_ADDR} | awk '{print $3}')"
DATACENTER="${2:-"dc1"}"
NODE_NAME="$(hostname)"

echo "--> Configuring nomad client"
sed -e "s/{{ network_interface }}/${NETWORK_INTERFACE}/g" \
    /vagrant/etc/nomad.d/client.hcl | sudo tee /etc/nomad.d/client.hcl
sed -e "s/{{ advertise_addr }}/${ADVERTISE_ADDR}/g" \
    -e "s/{{ datacenter }}/${DATACENTER}/g" \
    -e "s/{{ node_name }}/${NODE_NAME}/g" \
    /vagrant/etc/nomad.d/default.hcl | sudo tee /etc/nomad.d/default.hcl
