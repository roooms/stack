#!/usr/bin/env bash
set -e
#set -x

SCRIPT_PATH="$(dirname ${BASH_SOURCE[0]})"

bash ${SCRIPT_PATH}/reset-app.sh vault
bash ${SCRIPT_PATH}/reset-app.sh nomad
bash ${SCRIPT_PATH}/reset-app.sh consul
