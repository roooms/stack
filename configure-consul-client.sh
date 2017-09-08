#!/usr/bin/env bash
set -e
#set -x

SCRIPT_PATH="$(dirname ${BASH_SOURCE[0]})"
ADVERTISE_ADDR="$(ip route | grep "enp0s8" | awk '{print $9}')"
NODE_NAME="$(hostname --fqdn)"

echo "--> Configuring consul client"
sed -e "s/{{ advertise_addr }}/${ADVERTISE_ADDR}/g" \
    -e "s/{{ node_name }}/${NODE_NAME}/g" \
    ${SCRIPT_PATH}/config/etc_consul.d_default.json \
    | sudo tee /etc/consul.d/default.json
