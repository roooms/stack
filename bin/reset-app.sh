#!/usr/bin/env bash
set -e
#set -x

APP="${1:-"consul"}"

bash /vagrant/bin/stop-app.sh ${APP}

echo "--> Deleting any existing configuration and local data"
sudo rm -rf /etc/${APP}.d/*
sudo rm -rf /opt/${APP}/*
