#!/usr/bin/env bash
set -ex

APP="consul"
VERSION="0.8.0"
ZIP="${APP}_${VERSION}_linux_amd64.zip"
URL="https://releases.hashicorp.com/${APP}/${VERSION}/${ZIP}"
DATA_DIR="/var/lib/${APP}"
CONFIG_DIR="/etc/${APP}"
PUBLIC_IPV4="$(ifconfig | grep "10.0.0" | awk {'print $2'} | cut -d: -f2)"

echo "Downloading ${APP} ${VERSION}"
curl -O ${URL}
sudo unzip -o ${ZIP} -d /usr/local/bin/

echo "Installing ${APP}"
sudo chmod 755 /usr/local/bin/${APP}
sudo mkdir -p ${DATA_DIR}
sudo chmod 755 ${DATA_DIR}

echo "Configuring ${APP}"
cat > ${APP}.service <<'EOF'
[Unit]
Description=consul agent
Documentation=https://www.consul.io/docs/
[Service]
EnvironmentFile=-/etc/default/consul
Restart=on-failure
ExecStart=/usr/local/bin/consul agent \
-advertise=ADVERTISE_ADDR \
-bootstrap-expect 3 \
-data-dir=/var/lib/consul \
-retry-join=10.0.0.11 \
-retry-join=10.0.0.12 \
-retry-join=10.0.0.13 \
-server \
-ui \
$OPTIONS
ExecReload=/bin/kill -HUP $MAINPID
[Install]
WantedBy=multi-user.target
EOF
sed -e "s/ADVERTISE_ADDR/${PUBLIC_IPV4}/g" \
    -i ${APP}.service
sudo mv ${APP}.service /lib/systemd/system/

echo "Enabling and starting ${APP}"
sudo systemctl enable ${APP}
sudo systemctl start ${APP}
