#!/usr/bin/env bash
set -e
#set -x

NODE_NAME="$(hostname)"

echo "--> Installing apache2"
sudo apt-get install apache2 --yes

cat > /tmp/index.html <<-EOF
  <html>
  <title>${NODE_NAME}</title>
  <body>${NODE_NAME}</body>
  </html>
EOF
sudo mv /tmp/index.html /var/www/html/index.html

cat > /tmp/web.json <<-EOF
{"service": {"name": "webserver", "port": 80}}
EOF
sudo mv /tmp/web.json /etc/consul.d/web.json
sudo systemctl restart consul
