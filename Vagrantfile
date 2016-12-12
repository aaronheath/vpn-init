# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/xenial64"

  config.vm.network "private_network", ip: "192.168.26.19"
  config.vm.network "forwarded_port", guest: 22, host: 26019

  config.vm.network "public_network", use_dhcp_assigned_default_route: true

  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2
  end

  #config.vm.provision "shell", path: "vm/setup.sh"

  config.vm.synced_folder ".", "/vagrant"
end
