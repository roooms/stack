advertise_addr = "{{ advertise_addr }}"
bind_addr = "0.0.0.0"
client_addr = "0.0.0.0"
datacenter = "{{ datacenter }}"
data_dir = "/opt/consul/"
encrypt = "Luj2FZWwlt8475wD1WtwUQ=="
performance {
  raft_multiplier = 1
}
retry_join = ["{{ retry_join }}"]
ui_config {
  enabled = true
}
