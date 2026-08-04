#######################################################################
#   This part loads config to enable dynamically generated scripts to be executed on VM's #
#######################################################################
# Explicitly require the YAML module
require 'yaml'

#######################################################################
##   Ensure vagrant-vbguest is present before any VM is touched      ##
#######################################################################
# The ubuntu/jammy64 box ships an old Guest Additions build. Left unmanaged,
# a Guest Additions/VirtualBox version mismatch can make the /vagrant shared
# folder silently fail to mount on a given node, which then starves that
# node's provisioning scripts of files they expect to be there (e.g. the
# join-cluster script). vagrant-vbguest keeps Guest Additions in sync
# automatically, so require it rather than just documenting it.
required_plugins = %w(vagrant-vbguest)
required_plugins.each do |plugin|
  unless Vagrant.has_plugin?(plugin)
    puts "Installing missing plugin: #{plugin}"
    unless system("vagrant plugin install #{plugin}")
      abort "Failed to install required plugin '#{plugin}'. Install it manually with: vagrant plugin install #{plugin}"
    end
    exec "vagrant #{ARGV.join(' ')}"
  end
end

Vagrant.configure(2) do |config|
  # Load the configuration data from the YAML file
  config_data = YAML.load_file('config.yaml')

#######################################################################
##Generate the kubeadm init command with pre-configured IP addresses ##
#######################################################################

  local_script_path = "./scripts/kube_init_script.sh"
  File.open(local_script_path, 'w') do |file|
    file.puts "#!/bin/bash"
    file.puts 'echo "[TASK 1] Initialize Kubernetes Cluster"'
    # Keep stderr in the log (not discarded) so a failed init leaves a
    # diagnosable trail - master.sh tails this file if kubeadm init exits
    # non-zero, but that's only useful if errors actually landed here.
    file.puts "sudo kubeadm init --apiserver-advertise-address=#{config_data['master']['master_ip']} --pod-network-cidr=#{config_data['master']['pod_network_cidr']} >> kubeinit.log 2>&1"
  end

  # Transfer the dynamically generated script to guest VM
  config.vm.provision "file", source: local_script_path, destination: "/tmp/scripts/kube_init_script.sh"

#######################################################################
###  Generate the /etc/hosts file to be deployed on every node      ###
#######################################################################

  local_hosts_path = "./scripts/hosts"
  # Update the hosts file with configured IP addresses
  File.open(local_hosts_path, 'w') do |file|
    file.puts "127.0.0.1 localhost"

    # Add master entry
    file.puts "#{config_data['master']['master_ip']} master master"

    # Add worker entries
    if config_data['NodeCount'] >= 1
      (1..config_data['NodeCount']).each do |i|
        worker_hostname = "worker#{i}"
        worker_ip = "#{config_data['worker']['ip_prefix']}#{i + config_data['worker']['start_index'] - 1}"
        file.puts "#{worker_ip} #{worker_hostname} #{worker_hostname}"
      end
    end

    # Add ipv6 context
    file.puts '# The following lines are desirable for IPv6 capable hosts'
    file.puts '::1     localhost ip6-localhost ip6-loopback'
    file.puts 'ff02::1 ip6-allnodes'
    file.puts 'ff02::2 ip6-allrouters'
  end
  # Transfer the dynamically generated hosts file to VM's.
  config.vm.provision "file", source: local_hosts_path, destination: "/tmp/scripts/hosts"

#######################################################################
##        Execute on each new VM the requirements.sh script          ##
#######################################################################

  # Define the amount of time given to the machine to complete reboot
  # Machines are brought up one at a time (not in parallel). 900s gives extra
  # headroom for transient host contention (antivirus scanning VM disk files,
  # unrelated host load, etc.) that can stall a guest mid-boot.
  config.vm.boot_timeout = 900 # Set the boot timeout to 15 minutes

  # Execute on each new machine the requirements.sh script
  config.vm.provision "shell", path: "./scripts/requirements.sh", args: config_data['NodeCount']

#######################################################################
##   Create and configure the Master node, and deploy the cluster   ###
#######################################################################

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

      # Create additional drives if defined in the config file
      if config_data['master']['additional_storage_drives'].to_i > 0 &&
          config_data['master']['additional_storage_drives'].to_i < 10
        Master_drives = (1..config_data['master']['additional_storage_drives']).to_a
        Master_drives.each do |hd|
          v.customize ['createhd', '--filename', "./volumes/master_disk#{hd}.vdi", '--variant', 'Standard', '--size', config_data['worker']['storage_drives_size'] * 1024]
          v.customize ['storageattach', :id, '--storagectl', 'SCSI', '--port', hd + 1, '--device', 0, '--type', 'hdd', '--medium', "./volumes/master_disk#{hd}.vdi"]
        end
      end

      v.name = "master"
      v.memory = config_data['master']['memory']
      v.cpus = config_data['master']['cpus']
    end
    master.vm.provision "shell", path: "./scripts/master.sh"
    master.vm.box_download_insecure = true
  end

#######################################################################
###   Create and configure the worker nodes and join the cluster    ###
#######################################################################
  # Kubernetes nodes
  if config_data['NodeCount'] >= 1
    (1..config_data['NodeCount']).each do |i|
      config.vm.define "worker#{i}" do |worker|
        worker.vm.box = "ubuntu/jammy64"
        worker.vm.hostname = "worker#{i}"
        worker.vm.network "private_network", ip: "#{config_data['worker']['ip_prefix']}#{i + config_data['worker']['start_index'] - 1}"
        worker.vm.provider "virtualbox" do |v|
          if config_data['worker']['worker_virt'].to_s.downcase == 'true'
            v.customize ["modifyvm", :id, "--hwvirtex", "on"]
            v.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
          end

          # Create additional drives if defined in the config file
          if config_data['worker']['additional_storage_drives'].to_i > 0 &&
              config_data['worker']['additional_storage_drives'].to_i < 10
            Worker_drives = (1..config_data['worker']['additional_storage_drives']).to_a
            Worker_drives.each do |hd|
              v.customize ['createhd', '--filename', "./volumes/worker#{i}_disk#{hd}.vdi", '--variant', 'Standard', '--size', config_data['worker']['storage_drives_size'] * 1024]
              v.customize ['storageattach', :id, '--storagectl', 'SCSI', '--port', hd + 1, '--device', 0, '--type', 'hdd', '--medium', "./volumes/worker#{i}_disk#{hd}.vdi"]
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
end
