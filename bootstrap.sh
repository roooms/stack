#!/usr/bin/env bash
set -e
#set -x

echo "--> Update apt"
sudo apt-get update --fix-missing
echo "--> Install base packages"
sudo apt-get install --yes zip unzip git make dnsmasq

echo "--> Configure dnsmasq"
cat > /tmp/10-consul <<'EOF'
server=/consul/127.0.0.1#8600
EOF
sudo mkdir -p /etc/dnsmasq.d
sudo mv /tmp/10-consul /etc/dnsmasq.d
sudo service dnsmasq restart
