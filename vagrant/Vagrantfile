ENV['VAGRANT_NO_PARALLEL'] = 'yes'
Vagrant.require_version ">=2.0.0"

def install_vagrant_plugin(name)
  unless Vagrant.has_plugin?(name)
    system("vagrant plugin install #{name}")
    exec "vagrant #{ARGV.join(' ')}"
  end
end

Vagrant.configure("2") do |config|
  install_vagrant_plugin("vagrant-disksize")
  config.vm.box = "ubuntu/focal64"
  config.vm.box_check_update = false
  config.vm.base_mac = nil
  config.disksize.size = '50GB'
  config.vm.provision "shell", path: "bootstrap.sh"
  config.vm.provider :virtualbox do |vb|
    vb.memory = 2048
    vb.cpus = 2
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
  end

  (1..3).each do |i|
    config.vm.define "node-#{i}" do |node|
      node.vm.box_check_update = false
      node.vm.hostname = "node-#{i}"
      node.vm.network "private_network", ip: "172.16.0.1#{i}"
      node.vm.provider "virtualbox" do |vb|
        vb.name = "node-#{i}"
      end
    end
  end
end
