# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.ssh.insert_key = false
  config.vm.box = "bento/ubuntu-16.04"
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "256"]
  end
  nodes = 6
  baseip = 10
  (1..nodes).each do |n|
    nodename = "node#{n}.local"
    nodeip = "10.0.0.#{baseip+n}"
    config.vm.define nodename do |node|
      node.vm.hostname = nodename
      node.vm.network :private_network, ip: nodeip
    end
  end
end
