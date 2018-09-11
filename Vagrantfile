# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.ssh.insert_key = false
  config.vm.box = "roooms/ubuntu-16.04" # https://github.com/roooms/vagrant-boxes
  config.vm.box_check_update = false
  config.vm.provider :virtualbox do |vb|
    vb.memory = 1024
    vb.cpus = 1
  end
  # servers
  sbaseip = 10
  (1..3).each do |n|
    config.vm.define nodename = "server#{n}.local" do |node|
      node.vm.hostname = nodename
      node.vm.network "private_network", ip: "10.0.0.#{sbaseip+n}"
    end
  end
  # clients
  cbaseip = 13
  (1..3).each do |n|
    config.vm.define nodename = "client#{n}.local" do |node|
      node.vm.hostname = nodename
      node.vm.network "private_network", ip: "10.0.0.#{cbaseip+n}"
    end
  end
end
