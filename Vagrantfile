# Explicitly require the YAML module
require 'yaml'

Vagrant.configure(2) do |config|
  # Source key variables from config file
  NodeCount = YAML.load_file('config.yaml')['NodeCount']
  api_server_address = YAML.load_file('config.yaml')['master']['master_ip']
  pod_network_cidr = YAML.load_file('config.yaml')['master']['pod_network_cidr']


  ### Due to Vagrant limitations we will have to generate the kubeadm init command ###
  ### separately in advance, and provide it as a script to be executed on the      ###
  ### master node after VM creation. This is necessary to allow IP addresses to be ###
  ### configured dynamically in the config.yaml file                               ###
  ####################################################################################

  # Define a path to store dynamically generated kubeadm init script locally
  local_script_path = "./scripts/kube_init_script.sh"

  # Generate the kubeadm init command with configured IP addresses
  File.open(local_script_path, 'w') do |file|
    file.puts "#!/bin/bash"
    file.puts 'echo "[TASK 1] Initialize Kubernetes Cluster"'
    file.puts "sudo kubeadm init --apiserver-advertise-address=#{api_server_address} --pod-network-cidr=#{pod_network_cidr} >> kubeinit.log 2>/dev/null"
  end

  # Transfer the dynamically generated script to master VM
  config.vm.provision "file", source: local_script_path, destination: "/tmp/kube_init_script.sh"
  ####################################################################################


  # Load the rest of config_data from config file
  config_data = YAML.load_file('config.yaml')

  # Define the amount of time given to the machine to complete reboot
  config.vm.boot_timeout = 600 # Set the boot timeout to 10 minutes

  # Execute on each new machine the requirements.sh script
  config.vm.provision "shell", path: "./scripts/requirements.sh", args: NodeCount

  # Kubernetes Master
  config.vm.define "master" do |master|
    master.vm.box = "ubuntu/jammy64"
    master.vm.hostname = "master"
    master.vm.network "private_network", ip: config_data['master']['master_ip']
    master.vm.provider "virtualbox" do |v|
      if config_data['master']['master_virt'].to_s.downcase == 'true'
        v.customize ["modifyvm", :id, "--hwvirtex", "on"]
        v.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
      end
      
      # Create additional drives if defined in config file
      if config_data['master']['additional_storage_drives'].to_i > 0 &&
           config_data['master']['additional_storage_drives'].to_i < 10
          Master_drives = (1..config_data['master']['additional_storage_drives']).to_a
          Master_drives.each do |hd|
            v.customize ['createhd', '--filename', "./volumes/master_disk#{hd}.vdi", '--variant', 'Standard', '--size', config_data['worker']['storage_drives_size'] * 1024]
            v.customize ['storageattach', :id, '--storagectl', 'SCSI', '--port', hd+1, '--device', 0, '--type', 'hdd', '--medium', "./volumes/master_disk#{hd}.vdi"]
          end
      end

      v.name = "master"
      v.memory = config_data['master']['memory']
      v.cpus = config_data['master']['cpus']
    end
    master.vm.provision "shell", path: "./scripts/master.sh"
    master.vm.box_download_insecure = true
  end

  # Kubernetes nodes
  (1..NodeCount).each do |i|
    config.vm.define "worker#{i}" do |worker|
      worker.vm.box = "ubuntu/jammy64"
      worker.vm.hostname = "worker#{i}"
      worker.vm.network "private_network", ip: "#{config_data['worker']['ip_prefix']}#{i + config_data['worker']['start_index']}"
      worker.vm.provider "virtualbox" do |v|
        if config_data['worker']['worker_virt'].to_s.downcase == 'true'
          v.customize ["modifyvm", :id, "--hwvirtex", "on"]
          v.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
        end

      # Create additional drives if defined in config file
        if config_data['worker']['additional_storage_drives'].to_i > 0 &&
             config_data['worker']['additional_storage_drives'].to_i < 10
            Worker_drives = (1..config_data['worker']['additional_storage_drives']).to_a
            Worker_drives.each do |hd|
               v.customize ['createhd', '--filename', "./volumes/worker#{i}_disk#{hd}.vdi", '--variant', 'Standard', '--size', config_data['worker']['storage_drives_size'] * 1024]
               v.customize ['storageattach', :id, '--storagectl', 'SCSI', '--port', hd+1, '--device', 0, '--type', 'hdd', '--medium', "./volumes/worker#{i}_disk#{hd}.vdi"]
             end
        end

        v.name = "worker#{i}"
        v.memory = config_data['worker']['memory']
        v.cpus = config_data['worker']['cpus']
      end
      worker.vm.provision "shell", path: "./scripts/worker.sh"
      worker.vm.box_download_insecure = true
    end
  end
end
