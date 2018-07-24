#!/usr/bin/env bash
set -e
#set -x

NODE_NAME="$(hostname)"

#/vagrant/examples/hashistack/setup-hashistack-cluster.sh

case ${NODE_NAME} in
  node1 )
    consul kv put service/haproxy/maxconn 5
    consul kv put service/haproxy/mode http
    consul kv put service/haproxy/timeouts/connect 5000
    consul kv put service/haproxy/timeouts/client 10000
    consul kv put service/haproxy/timeouts/server 10000
    /vagrant/bin/install-haproxy.sh
  ;;
  node4 | node5 | node6 )
    /vagrant/bin/install-apache.sh
  ;;
  * )
  ;;
esac
