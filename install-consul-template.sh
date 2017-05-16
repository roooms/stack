#!/usr/bin/env bash
set -ex

APP="consul-template"
VERSION="0.18.3"
ZIP="${APP}_${VERSION}_linux_amd64.zip"
URL="https://releases.hashicorp.com/${APP}/${VERSION}/${ZIP}"
DOWNLOAD_DIR="/tmp"

echo "Downloading ${APP} ${VERSION}"
pushd ${DOWNLOAD_DIR}
curl -O ${URL}
popd

echo "Installing ${APP}"
sudo unzip -o ${DOWNLOAD_DIR}/${ZIP} -d /usr/local/bin/
sudo chmod 755 /usr/local/bin/${APP}
