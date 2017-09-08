#!/usr/bin/env bash
set -e
#set -x

SCRIPT_PATH="$(dirname ${BASH_SOURCE[0]})"
ADVERTISE_ADDR="$(ip route | grep "enp0s8" | awk '{print $9}')"
NODE_NAME="$(hostname)"

echo "--> Configuring nomad client"
sudo cp ${SCRIPT_PATH}/config/etc_nomad.d_client.hcl /etc/nomad.d/client.hcl
sed -e "s/{{ advertise_addr }}/${ADVERTISE_ADDR}/g" \
    -e "s/{{ node_name }}/${NODE_NAME}/g" \
    ${SCRIPT_PATH}/config/etc_nomad.d_default.hcl \
    | sudo tee /etc/nomad.d/default.hcl
