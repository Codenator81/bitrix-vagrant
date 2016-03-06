Vagrant.configure(2) do |config|
    config.vm.box = "ubuntu/trusty64"
    config.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--memory", "2000"]
    end
    config.vm.network "forwarded_port", guest: 80, host: 8089
    config.vm.network "forwarded_port", guest: 3306, host: 33060
    
    config.vm.network :private_network, ip: "198.168.50.50"
    
    config.vm.synced_folder ".", "/home/vagrant", nfs: true
    config.vm.provision :shell, path: "bootstrap.sh" 
end