#!/usr/bin/env bash
set -e
#set -x

cat > /tmp/register-google-search.json -<<EOF
{
    "Datacenter": "dc1",
    "Node": "google",
    "Address": "www.google.com",
    "NodeMeta": {
        "external-node": "true",
        "external-probe": "true"
    },
    "Service": {
        "Service": "search",
        "Port": 80
    },
    "Check": {
        "Node": "google",
        "CheckID": "service:search",
        "Name": "Google HTTP check",
        "Notes": "",
        "Status": "passing",
        "ServiceID": "search",
        "Definition": {
            "TCP": "www.google.com:80",
            "Interval": "5s",
            "Timeout": "1s",
            "DeregisterCriticalServiceAfter": "30s"
        }
    }
}
EOF

cat > /tmp/register-web-apache.json -<<EOF
{
    "Datacenter": "dc1",
    "Node": "web",
    "Address": "10.0.0.14",
    "NodeMeta": {
        "external-node": "true",
        "external-probe": "true"
    },
    "Service": {
        "Service": "apache",
        "Port": 80
    },
    "Check": {
        "Node": "web",
        "CheckID": "service:apache",
        "Name": "Web HTTP check",
        "Notes": "",
        "Status": "passing",
        "ServiceID": "apache",
        "Definition": {
            "TCP": "localhost:80",
            "Interval": "5s",
            "Timeout": "1s",
            "DeregisterCriticalServiceAfter": "30s"
        }
    }
}
EOF

cat > /tmp/deregister-google-search.json -<<EOF
{
    "Datacenter": "dc1",
    "Node": "google",
    "ServiceID": "search"
}
EOF

cat > /tmp/deregister-web-apache.json -<<EOF
{
    "Datacenter": "dc1",
    "Node": "web"
}
EOF

cat > /tmp/deregister-google.json -<<EOF
{
    "Datacenter": "dc1",
    "Node": "google"
}
EOF

# Register external service
curl -v --request PUT \
     --data @/tmp/register-web-apache.json \
     http://127.0.0.1:8500/v1/catalog/register

# Deregister external service
#curl -v --request PUT \
#     --data @/tmp/deregister-web-apache.json \
#     http://127.0.0.1:8500/v1/catalog/deregister

#check seems to show as passing when no esm check takes place
#how can you confirm health when a check is specified but nothing is performing the check?
