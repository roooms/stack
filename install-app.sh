#!/usr/bin/env bash
set -e
#set -x

APP="${1:-"consul"}"
VERSION="${2:-"0.9.2"}"
ZIP="${3:-"${APP}_${VERSION}_linux_amd64.zip"}"
URL="https://releases.hashicorp.com/${APP}/${VERSION}/${ZIP}"
CONFIG_DIR="/etc/${APP}"
DATA_DIR="/var/lib/${APP}"

if [[ ! -f $(which unzip) ]]; then
  echo "--> Unable to find unzip"
  sudo apt-get install -y unzip
fi

if [[ -f /vagrant/setup/${ZIP} ]]; then
  echo "--> Found /vagrant/setup/${ZIP}"
  sudo unzip -q -o /vagrant/setup/${ZIP} -d /usr/local/bin/
else
  echo "--> Attempting download of ${APP} ${VERSION} to /tmp/${ZIP}"
  pushd /tmp > /dev/null
  if curl -s -O ${URL}; then
    echo "--> Downloaded ${ZIP}"
    popd > /dev/null
    sudo unzip -q -o /tmp/${ZIP} -d /usr/local/bin/
  else
    echo "--> Unable to download ${ZIP}"
    popd > /dev/null
  fi
fi

echo "--> Installing ${APP}"
sudo chmod 755 /usr/local/bin/${APP}
sudo mkdir -p ${CONFIG_DIR}
sudo chmod 755 ${CONFIG_DIR}
sudo mkdir -p ${DATA_DIR}
sudo chmod 755 ${DATA_DIR}
