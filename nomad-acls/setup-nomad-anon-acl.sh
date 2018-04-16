#!/usr/bin/env bash
set -e
#set -x

# shellcheck disable=SC1091
source /etc/profile.d/nomad.sh

cat > /tmp/payload.json <<EOF
{
    "Name": "anonymous",
    "Description": "Allow read-only access for anonymous requests",
    "Rules": "
        namespace \"default\" {
            policy = \"read\"
        }
        agent {
            policy = \"read\"
        }
        node {
            policy = \"read\"
        }
    "
}
EOF

curl --request POST --data @/tmp/payload.json -H "X-Nomad-Token: ${NOMAD_TOKEN}" http://localhost:4646/v1/acl/policy/anonymous
