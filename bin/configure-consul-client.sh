#!/usr/bin/env bash
set -e
#set -x

ADVERTISE_ADDR="$(hostname -I | awk '{print $2}')"
DATACENTER="${3:-"dc1"}"
ACL_DATACENTER="${4:-$DATACENTER}"
NODE_NAME="$(hostname)"
RETRY_JOIN="10.0.0.${2:-"11"}"

echo "--> Configuring consul client"
sed -e "s/{{ advertise_addr }}/${ADVERTISE_ADDR}/g" \
    -e "s/{{ datacenter }}/${DATACENTER}/g" \
    -e "s/{{ acl_datacenter }}/${ACL_DATACENTER}/g" \
    -e "s/{{ node_name }}/${NODE_NAME}/g" \
    -e "s/{{ retry_join }}/${RETRY_JOIN}/g" \
    /vagrant/etc/consul.d/default.json \
    | sudo tee /etc/consul.d/default.json
