name = "{{ node_name }}"
data_dir = "/opt/nomad"
advertise {
  http = "{{ advertise_addr }}"
  rpc = "{{ advertise_addr }}"
  serf = "{{ advertise_addr }}"
}