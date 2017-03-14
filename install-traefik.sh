#!/usr/bin/env bash
set -ex

consul kv put traefik/backends/consul_ui/servers/server1/url http://127.0.0.1:8500
consul kv put traefik/consul/endpoint 127.0.0.1:8500
consul kv put traefik/consul/prefix traefik
consul kv put traefik/consul/watch true
consul kv put traefik/defaultentrypoints/0 http
consul kv put traefik/entrypoints/http/address :8080
consul kv put traefik/frontends/consul_ui/backend consul_ui
consul kv put traefik/frontends/consul_ui/passHostHeader true
consul kv put traefik/loglevel DEBUG
consul kv put traefik/web/address :8081

#nomad run jobs/traefik.nomad
