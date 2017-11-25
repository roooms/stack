backend "consul" {
  address = "127.0.0.1:8500"
  path = "vault/"
}
listener "tcp" {
  address = "{{ vault_ip }}:8200"
  tls_disable = "true"
}
ui = true