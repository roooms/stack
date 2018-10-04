server = true
bootstrap_expect = 0
service {
  name = "consul"
  tags = ["{{ node_name }}"]
}
connect {
  enabled = true
  proxy {
    allow_managed_root = true
  }
}
