#!/usr/bin/env bash
set -e
#set -x

ADVERTISE_ADDR="$(ip route | grep "enp0s8" | awk '{print $9}')"
BOOTSTRAP_EXPECT="${1:-"3"}"
DATACENTER="${3:-"dc1"}"
ACL_DATACENTER="${4:-$DATACENTER}"
NODE_NAME="$(hostname)"
RETRY_JOIN="10.0.0.${2:-"11"}"

echo "--> Configuring consul server"
sed -e "s/{{ advertise_addr }}/${ADVERTISE_ADDR}/g" \
    -e "s/{{ datacenter }}/${DATACENTER}/g" \
    -e "s/{{ acl_datacenter }}/${ACL_DATACENTER}/g" \
    -e "s/{{ node_name }}/${NODE_NAME}/g" \
    -e "s/{{ retry_join }}/${RETRY_JOIN}/g" \
    /vagrant/etc/consul.d/default.json \
    | sudo tee /etc/consul.d/default.json
sed -e "s/0/${BOOTSTRAP_EXPECT}/g" \
    -e "s/{{ node_name }}/${NODE_NAME}/g" \
    /vagrant/etc/consul.d/server.json \
    | sudo tee /etc/consul.d/server.json
