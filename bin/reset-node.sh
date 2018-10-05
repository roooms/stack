#!/usr/bin/env bash
set -e
#set -x

reset-app() {
if [[ -f $(command -v "$1") ]]; then
  bash /vagrant/bin/reset-app.sh "$1"
fi
}

reset-app vault
reset-app nomad
reset-app consul
