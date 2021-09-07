#!/usr/bin/env bash
set -e
#set -x

APP="${1:-"consul"}"
VERSION="${2:-""}"
CONFIG_DIR="/etc/${APP}.d"
DATA_DIR="/opt/${APP}"

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update --fix-missing

if [[ "${VERSION}" = "" ]]; then
  VERSION_TAG=""
else
  VERSION_TAG="=${VERSION}"
fi
echo "--> Installing ${APP} ${VERSION}"
sudo apt-get install ${APP}${VERSION_TAG}

if [[ ! -f $(command -v unzip) ]]; then
  echo "--> Installing unzip"
  sudo apt-get install -y unzip
fi

if [[ ! -f $(command -v jq) ]]; then
  echo "--> Installing jq"
  sudo apt-get install -y jq
fi

if id "${APP}" >/dev/null 2>&1; then
  echo "--> Dedicated user for ${APP} already exists"
else
  echo "--> Adding dedicated ${APP} user and group"
  sudo useradd --system --home ${CONFIG_DIR} --shell /bin/false ${APP}
fi

case ${APP} in
  consul | nomad | vault )
    if grep complete ~/.bashrc | grep "${APP}" >/dev/null 2>&1; then
      echo "--> Autocomplete for ${APP} already installed"
    else
      echo "--> Installing autocomplete for ${APP}"
      ${APP} -autocomplete-install
      complete -C /usr/local/bin/${APP} ${APP}
    fi
  ;;
  * )
  ;;
esac

#if [[ -f /vagrant/etc/systemd/system/${APP}.service ]]; then
#  echo "--> Installing systemd ${APP}.service"
#  sudo cp /vagrant/etc/systemd/system/${APP}.service /etc/systemd/system/${APP}.service
#fi
