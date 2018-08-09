ca_file   = "/etc/consul.d/tls/consul-ca.pem"
cert_file = "/etc/consul.d/tls/consul-{{ agent_type }}.pem"
key_file  = "/etc/consul.d/tls/consul-{{ agent_type }}-key.pem"
ports {
  http = -1
  https = 8500
}
verify_incoming = false
verify_incoming_rpc = false
verify_outgoing = false
