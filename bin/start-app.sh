#!/usr/bin/env bash
set -e
#set -x

APP="${1:-"consul"}"

echo "--> Enabling and starting ${APP}"
sudo systemctl enable ${APP}
sudo systemctl start ${APP}
