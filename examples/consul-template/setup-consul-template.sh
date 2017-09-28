#!/usr/bin/env bash
set -e
#set -x

SCRIPT_PATH="/vagrant/bin"

bash ${SCRIPT_PATH}/install-app.sh consul-template 0.19.3
