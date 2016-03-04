Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.network "forwarded_port", guest: 80, host: 8088
  config.vm.network "forwarded_port", guest: 3306, host: 33060
  config.vm.synced_folder ".", "/home/vagrant"
  config.vm.provision :shell, path: "bootstrap.sh" 
end
