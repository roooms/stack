#!/usr/bin/env bash
set -e
#set -x

APP="${1:-"consul"}"

bash /vagrant/bin/stop-app.sh ${APP}

echo "--> Removing any existing configuration and local data"
sudo rm -rf /etc/${APP}.d/*
sudo rm -rf /opt/${APP}/*
sudo rm -f /etc/profile.d/${APP}.sh

if [[ ${APP} = "vault" ]]; then
    for file in "${HOME}/.vault-token" "/etc/profile.d/vault.sh"; do
        if [[ -f $file ]]; then
            echo "--> Removing ${file}"
            sudo rm "${file}"
        fi
    done
fi
