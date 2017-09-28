name = "{{ node_name }}"
data_dir = "/opt/nomad"
datacenter = "{{ datacenter }}"
advertise {
  http = "{{ advertise_addr }}"
  rpc = "{{ advertise_addr }}"
  serf = "{{ advertise_addr }}"
}
