#!/usr/bin/env bash
set -e
#set -x

if [[ ! -f $(which docker) ]]; then
  echo "--> Adding docker keyserver"
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &>/dev/null

  echo "--> Adding docker repo"
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

  echo "--> Updating cache"
  sudo apt-get update --fix-missing

  echo "--> Installing docker"
  sudo apt-get install docker-ce --yes

  echo "--> Allowing docker without sudo"
  sudo usermod -aG docker "$(whoami)"
fi
