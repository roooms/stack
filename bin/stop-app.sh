#!/usr/bin/env bash
set -e
#set -x

APP="${1:-"consul"}"

echo "--> Stopping and disabling ${APP}"
sudo systemctl stop ${APP}
sudo systemctl disable ${APP}
sudo systemctl daemon-reload
