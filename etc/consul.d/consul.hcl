advertise_addr = "{{ advertise_addr }}"
bind_addr = "0.0.0.0"
client_addr = "0.0.0.0"
datacenter = "dc2"
data_dir = "/tmp/consul"
log_level = "DEBUG"
performance {
  raft_multiplier = 1
}
retry_join = ["{{ retry_join }}"]
ui = true
