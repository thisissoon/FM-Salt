Vagrant.configure('2') do |config|

  vm_box = 'ubuntu/trusty64'

  config.hostsupdater.remove_on_suspend = true

  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 2
  end

  # The Salt Master VM
  config.vm.define :master do |master|
    master.vm.box = vm_box
    master.vm.box_check_update = true
    master.hostsupdater.aliases = ["salt.soonfm.internal", "etcd.soonfm.internal"]
    master.vm.network :private_network, ip: '192.168.37.10'
    master.vm.hostname = 'salt.soonfm.internal'
    master.vm.provision :shell, path: "master_bootstrap.sh"
    master.vm.synced_folder "./states", "/srv/salt", type: "nfs"
    master.vm.synced_folder "./master.d", "/etc/salt/master.d", type: "nfs"
  end

  # The Minion VM
  config.vm.define :minion do |minion|
    minion.vm.box = vm_box
    minion.vm.box_check_update = true
    minion.vm.network :private_network, ip: '192.168.37.11'
    minion.vm.hostname = 'minion.soonfm.internal'
    minion.vm.provision :shell, path: "minion_bootstrap.sh"
  end

end
