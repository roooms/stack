#!/usr/bin/env bash
set -ex

sudo apt-get update --fix-missing
sudo apt-get install --yes zip unzip git make dnsmasq

# configure dnsmasq
cat > 10-consul <<'EOF'
server=/consul/127.0.0.1#8600
EOF
sudo mkdir -p /etc/dnsmasq.d
sudo mv 10-consul /etc/dnsmasq.d
sudo service dnsmasq restart
