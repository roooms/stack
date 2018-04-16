#!/usr/bin/env bash
set -e
#set -x

echo "--> Installing haproxy"
sudo apt-get install haproxy --yes
echo "ENABLED=1" | sudo tee /etc/default/haproxy
cat > "/tmp/haproxy.conf.ctmpl" <<-EOF
global
    log /dev/log    local0
    log /dev/log    local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

defaults
    mode {{key "service/haproxy/mode"}}{{range ls "service/haproxy/timeouts"}}
    timeout {{.Key}} {{.Value}}{{end}}

listen webserver
    bind *:80{{range service "webserver"}}
    server {{.Node}} {{.Address}}:{{.Port}}{{end}}
EOF
consul-template -template="/tmp/haproxy.conf.ctmpl:/tmp/haproxy.conf" -once
sudo cp /tmp/haproxy.conf /etc/haproxy/haproxy.cfg
sudo systemctl restart haproxy
