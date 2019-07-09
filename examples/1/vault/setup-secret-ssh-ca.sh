#!/usr/bin/env bash
set -e
#set -x

# shellcheck disable=SC1091
source /etc/profile.d/vault.sh

VAULT_TOKEN="$(consul kv get vault-root-token)"
export VAULT_TOKEN

# Add some local user accounts
sudo useradd alice
sudo useradd brian
sudo useradd chris
sudo useradd donna

# Setup SSH CA secrets engine
vault secrets enable -path=ssh-client-signer ssh

# Configure the public private key pair (Vault generated)
vault write ssh-client-signer/config/ca generate_signing_key=true

# Create a role named vagrant which allows any user to authenticate as vagrant 
vault write ssh-client-signer/roles/vagrant -<<"EOH"
{
  "allow_user_certificates": true,
  "allowed_users": "vagrant",
  "default_extensions": [
    {
      "permit-pty": ""
    }
  ],
  "key_type": "ca",
  "default_user": "vagrant",
  "ttl": "2m0s"
}
EOH

# Create a role named ops-team which allows authentication as ops-team users
vault write ssh-client-signer/roles/ops-team -<<"EOH"
{
  "allow_user_certificates": true,
  "allowed_users": "alice, brian, chris, donna",
  "default_extensions": [
    {
      "permit-pty": ""
    }
  ],
  "key_type": "ca",
  "ttl": "2m0s"
}
EOH

# Create an example key pair for Vault to sign
ssh-keygen -t rsa -N "" -C "vault-ssh-ca@example.com" -f /tmp/vault_ssh_ca_example

# Send the public key of the newly created key pair to vault via the API for signing
vault write -field=signed_key ssh-client-signer/sign/vagrant \
  public_key=@/tmp/vault_ssh_ca_example.pub \
  | tee /tmp/vagrant-signed-cert.pub
vault write -field=signed_key ssh-client-signer/sign/ops-team \
  public_key=@/tmp/vault_ssh_ca_example.pub \
  valid_principals=alice \
  | tee /tmp/ops-team-signed-cert.pub

# On every host you want to connect to add the public key
curl http://10.0.0.11:8200/v1/ssh-client-signer/public_key | sudo tee -a /etc/ssh/trusted-user-ca-keys.pem
echo "TrustedUserCAKeys /etc/ssh/trusted-user-ca-keys.pem" | sudo tee -a /etc/ssh/sshd_config
echo "LogLevel VERBOSE" | sudo tee -a /etc/ssh/sshd_config
sudo systemctl restart ssh

ssh-keygen -Lf /tmp/ops-team-signed-cert.pub
ssh -i /tmp/vault_ssh_ca_example -i /tmp/ops-team-signed-cert.pub alice@10.0.0.11
