#!/usr/bin/env bash
set -ex

APP="vault"
VERSION="0.7.2"
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
# vault systemd script
cat > ${APP}.service <<'EOF'
[Unit]
Description=vault server
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target

[Service]
EnvironmentFile=-/etc/default/vault
ExecStart=/usr/local/bin/vault server $OPTIONS -config=/etc/vault/

[Install]
WantedBy=multi-user.target
EOF
sudo mv ${APP}.service /lib/systemd/system/
# vault configuration file
cat > default.hcl <<'EOF'
backend "consul" {
  address = "127.0.0.1:8500"
  path = "vault/"
}

listener "tcp" {
  address = "ADDRESS:8200"
  tls_disable = "true"
}
EOF
sed -e "s/ADDRESS/${PUBLIC_IPV4}/g" \
    -i default.hcl
sudo mv default.hcl ${CONFIG_DIR}
# env configuration
echo "export VAULT_ADDR=http://${PUBLIC_IPV4}:8200" | sudo tee /etc/profile.d/${APP}.sh
sudo chmod 644 /etc/profile.d/${APP}.sh

echo "Enabling and starting ${APP}"
sudo systemctl enable ${APP}
sudo systemctl start ${APP}
