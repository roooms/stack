#!/usr/bin/env bash
set -ex

APP="consul-template"
VERSION="0.18.2"
ZIP="${APP}_${VERSION}_linux_amd64.zip"
URL="https://releases.hashicorp.com/${APP}/${VERSION}/${ZIP}"

echo "Downloading ${APP} ${VERSION}"
curl -O ${URL}
sudo unzip -o ${ZIP} -d /usr/local/bin/

echo "Installing ${APP}"
sudo chmod 755 /usr/local/bin/${APP}
