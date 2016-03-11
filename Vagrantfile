Vagrant.configure('2') do |config|

  vm_box = 'ubuntu/trusty64'

  config.hostsupdater.remove_on_suspend = true

  config.vm.provider "vmware_fusion" do |v|
    vm_box = 'phusion/ubuntu-14.04-amd64'
  end

  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 2
  end

  # The Salt Master VM
  config.vm.define :master do |master|
    master.vm.box = vm_box
    master.vm.box_check_update = true
    master.hostsupdater.aliases = ["salt", "fm.salt.local", "fm.etcd.local"]
    master.vm.network :private_network, ip: '192.168.37.10'
    master.vm.hostname = 'fm.salt.local'
    master.vm.provision :shell, path: "master_bootstrap.sh"
    master.vm.synced_folder "./states", "/srv/salt", type: "nfs"
    master.vm.synced_folder "./master.d", "/etc/salt/master.d", type: "nfs"
  end

end
