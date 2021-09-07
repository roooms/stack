listener "tcp" {
  address = "{{ vault_ip }}:8200"
  tls_disable = "true"
}
ui = true
plugin_directory = "/etc/vault.d/plugins"
