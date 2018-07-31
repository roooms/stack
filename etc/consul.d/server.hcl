server = true
bootstrap_expect = 0
service {
  name = "consul"
  tags = ["{{ node_name }}"]
}
