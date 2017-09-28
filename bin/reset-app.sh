#!/usr/bin/env bash
set -e
#set -x

APP="${1:-"consul"}"

echo "--> Stopping and disabling ${APP}"
sudo systemctl stop ${APP}
sudo systemctl disable ${APP}
sudo systemctl daemon-reload

echo "--> Deleting any existing configuration and local data"
sudo rm -rf /etc/${APP}.d/*
sudo rm -rf /opt/${APP}/*
