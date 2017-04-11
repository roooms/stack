#!/usr/bin/env bash
set -ex

APP="nomad"
VERSION="0.5.6"
ZIP="${APP}_${VERSION}_linux_amd64.zip"
URL="https://releases.hashicorp.com/${APP}/${VERSION}/${ZIP}"
DATA_DIR="/var/lib/${APP}"
CONFIG_DIR="/etc/${APP}"
PUBLIC_IPV4="$(ifconfig | grep "10.0.0" | awk {'print $2'} | cut -d: -f2)"
INTERFACE_NAME="$(ifconfig | grep -B1 "10.0.0" | head -1 | awk {'print $1'})"

echo "Downloading ${APP} ${VERSION}"
curl -O ${URL}
sudo unzip -o ${ZIP} -d /usr/local/bin/

echo "Installing ${APP}"
sudo chmod 755 /usr/local/bin/${APP}
sudo mkdir -p ${DATA_DIR}
sudo chmod 755 ${DATA_DIR}
sudo mkdir -p ${CONFIG_DIR}
sudo chmod 755 ${CONFIG_DIR}

echo "Configuring ${APP}"
# create nomad systemd file
cat > ${APP}.service <<'EOF'
[Unit]
Description=nomad agent
Documentation=https://www.nomadproject.io/docs/
Requires=network-online.target
After=network-online.target

[Service]
EnvironmentFile=-/etc/default/nomad
ExecStart=/usr/local/bin/nomad agent $OPTIONS -config=/etc/nomad/

[Install]
WantedBy=multi-user.target
EOF
sudo mv ${APP}.service /lib/systemd/system/
# create nomad configuration file
cat > default.hcl <<'EOF'
advertise {
  http = "ADVERTISE_ADDR"
  rpc = "ADVERTISE_ADDR"
  serf = "ADVERTISE_ADDR"
}
data_dir = "/var/lib/nomad"
client {
  enabled = true
  network_interface = "INTERFACE_NAME"
}
EOF
sed -e "s/ADVERTISE_ADDR/${PUBLIC_IPV4}/g" \
    -e "s/INTERFACE_NAME/${INTERFACE_NAME}/g" \
    -i default.hcl
sudo mv default.hcl $CONFIG_DIR

echo "Enabling and starting ${APP}"
sudo systemctl enable ${APP}
sudo systemctl start ${APP}
