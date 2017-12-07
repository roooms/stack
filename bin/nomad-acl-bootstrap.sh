#!/usr/bin/env bash
set -e
#set -x

get_leader_http_code() {  
  curl -w %{http_code} -s http://127.0.0.1:4646/v1/status/leader -o /dev/null
}
get_leader_ipv4() {
  curl -s http://127.0.0.1:4646/v1/status/leader | jq -r . | cut -d: -f1
}
get_local_ipv4() {
  hostname -I | awk '{print $2}'
}

# get the HTTP response code from /v1/status/leader
LEADER_HTTP_CODE=$(get_leader_http_code)
# wait until the API returns a 200 
while [ "${LEADER_HTTP_CODE}" -ne 200 ]; do
  echo "--> Waiting for HTTP 200 from http://127.0.0.1:4646/v1/status/leader"
  echo "--> Sleeping for 5 seconds"
  sleep 5
  LEADER_HTTP_CODE=$(get_leader_http_code)
done

# get the local and leader ip addresses
LOCAL_IPV4=$(get_local_ipv4)
LEADER_IPV4=$(get_leader_ipv4)

# if the local ip address matches the leaders then run acl bootstrap
if [ "${LOCAL_IPV4}" = "${LEADER_IPV4}" ]; then
  echo "--> Leader"
  echo "--> Bootstrapping nomad acl"
  nomad acl bootstrap | tee /tmp/nomad.bootstrap
  NOMAD_TOKEN="$(grep '^Secret' /tmp/nomad.bootstrap | awk '{print $4}')"
  echo "export NOMAD_TOKEN=${NOMAD_TOKEN}" | sudo tee /etc/profile.d/nomad.sh
  sudo chmod 644 /etc/profile.d/nomad.sh
  # shred the output
  shred /tmp/nomad.bootstrap
else
  echo "--> Not leader"
  echo "--> Skipping bootstrap"
fi
