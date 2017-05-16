#!/usr/bin/env bash
set -ex

APP="nomad"
VERSION="0.5.6"
ZIP="${APP}_${VERSION}_linux_amd64.zip"
URL="https://releases.hashicorp.com/${APP}/${VERSION}/${ZIP}"
CONFIG_DIR="/etc/${APP}"
DATA_DIR="/var/lib/${APP}"
DOWNLOAD_DIR="/tmp"
PUBLIC_IPV4="$(ip route | grep -v "10.0.2" | awk '{print $9}')"

if [[ ! -f /vagrant/zips/${ZIP} ]]; then
  echo "Downloading ${APP} ${VERSION}"
  pushd ${DOWNLOAD_DIR}
  curl -O ${URL}
  popd
else
  echo "Found /vagrant/zips/${ZIP}"
  DOWNLOAD_DIR="/vagrant/zips"
fi

echo "Installing ${APP}"
sudo unzip -o ${DOWNLOAD_DIR}/${ZIP} -d /usr/local/bin/
sudo chmod 755 /usr/local/bin/${APP}
sudo mkdir -p ${CONFIG_DIR}
sudo chmod 755 ${CONFIG_DIR}
sudo mkdir -p ${DATA_DIR}
sudo chmod 755 ${DATA_DIR}

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
server {
  enabled = true
  bootstrap_expect = 3
}
EOF
sed -e "s/ADVERTISE_ADDR/${PUBLIC_IPV4}/g" \
    -i default.hcl
sudo mv default.hcl ${CONFIG_DIR}

echo "Enabling and starting ${APP}"
sudo systemctl enable ${APP}
sudo systemctl start ${APP}
