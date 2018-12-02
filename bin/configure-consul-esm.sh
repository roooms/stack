#!/usr/bin/env bash
set -e
#set -x

ADVERTISE_ADDR="$(hostname -I | awk '{print $2}')"
DATACENTER="${3:-"dc1"}"
ACL_DATACENTER="${4:-$DATACENTER}"
NODE_NAME="$(hostname)"
RETRY_JOIN="${2:-"10.0.0.11"}"

echo "--> Configuring consul esm"
sed -e "s/{{ datacenter }}/${DATACENTER}/g" \
    /vagrant/etc/consul-esm.d/default.hcl | sudo tee /etc/consul-esm.d/default.hcl
