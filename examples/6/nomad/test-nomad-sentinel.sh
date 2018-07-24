#!/usr/bin/env bash
set -e
#set -x

cat > /tmp/test.sentinel <<EOF
# Test policy always fails for demonstration purposes
main = rule { false }
EOF

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

nomad agent -config /tmp/config.hcl 2> /tmp/error.log > /tmp/console.log &
sleep 10

nomad acl bootstrap > /tmp/acl_bootstrap.txt

NOMAD_TOKEN="$(grep "Secret ID" /tmp/acl_bootstrap.txt | awk '{print $4}')"
export NOMAD_TOKEN

curl --request POST --data @/tmp/payload.json -H "X-Nomad-Token: $NOMAD_TOKEN" http://127.0.0.1:4646/v1/acl/policy/anonymous

nomad sentinel apply -level=advisory test-policy /tmp/test.sentinel
