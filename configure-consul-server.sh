#!/usr/bin/env bash
set -e
#set -x

SCRIPT_PATH="$(dirname ${BASH_SOURCE[0]})"
BOOTSTRAP_EXPECT="${1:-"3"}"
ADVERTISE_ADDR="$(ip route | grep "enp0s8" | awk '{print $9}')"
NODE_NAME="$(hostname --fqdn)"

echo "--> Configuring consul server"
sed -e "s/{{ advertise_addr }}/${ADVERTISE_ADDR}/g" \
    -e "s/{{ node_name }}/${NODE_NAME}/g" \
    ${SCRIPT_PATH}/config/etc_consul.d_default.json \
    | sudo tee /etc/consul.d/default.json
sed -e "s/0/${BOOTSTRAP_EXPECT}/g" \
    -e "s/{{ node_name }}/${NODE_NAME}/g" \
    ${SCRIPT_PATH}/config/etc_consul.d_server.json \
    | sudo tee /etc/consul.d/server.json
