#!/usr/bin/env bash
set -e
#set -x

bash /vagrant/bin/reset-app.sh vault
bash /vagrant/bin/reset-app.sh nomad
bash /vagrant/bin/reset-app.sh consul
