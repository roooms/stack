tls {
  http = true
  rpc  = true

  ca_file   = "/etc/nomad.d/tls/nomad-ca.pem"
  cert_file = "/etc/nomad.d/tls/nomad-{{ agent_type }}.pem"
  key_file  = "/etc/nomad.d/tls/nomad-{{ agent_type }}-key.pem"

  verify_server_hostname = true
  verify_https_client    = true
}
