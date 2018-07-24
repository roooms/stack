#!/usr/bin/env bash
set -e
#set -x

# shellcheck disable=SC1091
source /etc/profile.d/vault.sh

VAULT_TOKEN="$(consul kv get vault-root-token)"
export VAULT_TOKEN

# Setup Root CA
vault secrets enable -description="Dan Root CA" -max-lease-ttl=87600h pki
vault write \
  pki/config/urls \
  issuing_certificates="http://vault.service.consul:8200/v1/pki/ca" \
  crl_distribution_points="http://vault.service.consul:8200/v1/pki/crl"

vault write pki/root/generate/internal \
  common_name="Dan Root CA" \
  ttl=87600h \
  key_bits=4096 \
  exclude_cn_from_sans=true
# https://www.vaultproject.io/api/secret/pki/index.html#exclude_cn_from_sans-2

curl -s -H "X-Vault-Token: $(consul kv get vault-root-token)" http://10.0.0.11:8200/v1/pki/ca/pem \
  | openssl x509 -text | head -15

# Setup Intermediate CA
vault secrets enable -path=pki_int -description="Dan Intermediate CA" -max-lease-ttl=43800h pki
vault write \
  pki_int/config/urls \
  issuing_certificates="http://vault.service.consul:8200/v1/pki_int/ca" \
  crl_distribution_points="http://vault.service.consul:8200/v1/pki_int/crl"

vault write -field=csr pki_int/intermediate/generate/internal \
  common_name="Dan Intermediate CA" \
  ttl=43800h \
  | tee pki_int.csr

vault write -field=certificate pki/root/sign-intermediate \
  csr=@pki_int.csr \
  format=pem_bundle \
  ttl=43800h \
  | tee pki_int.crt

vault write pki_int/intermediate/set-signed certificate=@pki_int.crt

curl -s -H "X-Vault-Token: $(consul kv get vault-root-token)" http://10.0.0.11:8200/v1/pki_int/ca/pem \
  | openssl x509 -text | head -15

# Setup Apache Role
vault write pki_int/roles/web_server \
  key_bits=2048 \
  max_ttl=8760h \
  allow_any_name=true

# Issue Certificate
vault write pki_int/issue/web_server \
  common_name="node4.local" \
  ip_sans="127.0.0.1,10.0.0.51" \
  ttl=720h \
  format=pem

# vault example at https://werner-dijkerman.nl/2017/08/25/automatically-generate-certificates-with-vault/
# nginx guide at http://cuddletech.com/?p=959
# nginx config at http://nginx.org/en/docs/http/configuring_https_servers.html
# store key and cert in files:
#   /etc/ssl/private/node4.local.key
#   /etc/ssl/certs/node4.local.pem
# nginx configuration looks like:
#   listen 443 ssl default_server;
#   listen [::]:443 ssl default_server;
#   ssl_certificate     /etc/ssl/certs/node4.local.pem;
#   ssl_certificate_key /etc/ssl/private/node4.local.key;

# issue a cert
curl -XPOST -s -H "X-Vault-Token: $(consul kv get vault-root-token)" \
-d '{"common_name":"node1.local","ip_sans":"127.0.0.1,10.0.0.51","ttl":"720h"}' \
http://10.0.0.51:8200/v1/pki_int/issue/web_server | jq

# list all issued certs
curl -XGET --request LIST -s -H "X-Vault-Token: $(consul kv get vault-root-token)" \
http://10.0.0.51:8200/v1/pki_int/certs | jq

# revoke an issued cert
curl -XPOST -H "X-Vault-Token: $(consul kv get vault-root-token)" \
-d '{"serial_number":"37-28-8c-ec-04-e0-0c-23-46-62-43-e7-57-11-81-89-30-08-83-b4"}' \
http://10.0.0.51:8200/v1/pki_int/revoke | jq
