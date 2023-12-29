# Explicitly require the YAML module
require 'yaml'

Vagrant.configure(2) do |config|
  # Use NodeCount directly
  NodeCount = YAML.load_file('initial_setup.yaml')['NodeCount']

  # Load config_data directly without using []
  config_data = YAML.load_file('initial_setup.yaml')

  # The amount of time given to machine to complete reboot
  config.vm.boot_timeout = 600 # Set the boot timeout to 10 minutes

  # execute on each new machine the requirements.sh script
  config.vm.provision "shell", path: "requirements.sh", args: NodeCount

  # Kubernetes Master
  config.vm.define "master" do |master|
    master.vm.box = "bento/ubuntu-22.04"
    master.vm.hostname = "master"
    master.vm.network "private_network", ip: config_data['master']['master_ip']
    master.vm.provider "virtualbox" do |v| 
      if config_data['master']['master_virt'].to_s.downcase == 'true'
        v.customize ["modifyvm", :id, "--hwvirtex", "on"]
        v.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
      end
      v.name = "master"
      v.memory = config_data['master']['memory']
      v.cpus = config_data['master']['cpus']
    end
    master.vm.provision "shell", path: "master.sh"
    master.vm.box_download_insecure = true
  end

  # Kubernetes nodes
  (1..NodeCount).each do |i|
    config.vm.define "worker#{i}" do |worker|
      worker.vm.box = "bento/ubuntu-22.04"
      worker.vm.hostname = "worker#{i}"
      worker.vm.network "private_network", ip: "#{config_data['worker']['ip_prefix']}#{i + config_data['worker']['start_index']}"
      worker.vm.provider "virtualbox" do |v|
        if config_data['worker']['worker_virt'].to_s.downcase == 'true'
          v.customize ["modifyvm", :id, "--hwvirtex", "on"]
          v.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
        end
        v.name = "worker#{i}"
        v.memory = config_data['worker']['memory']
        v.cpus = config_data['worker']['cpus']
      end
      worker.vm.provision "shell", path: "worker.sh"
      worker.vm.box_download_insecure = true
    end
  end
end
