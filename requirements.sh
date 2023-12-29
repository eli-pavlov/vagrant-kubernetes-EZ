#!/bin/bash

# Load variables from the YAML file
config_data=$(cat initial_setup.yaml | yq r -)

# Extract NodeCount
NodeCount=$(echo "${config_data}" | grep -E "NodeCount:" | awk '{print $2}')

# Update hosts file
echo "127.0.0.1 localhost" | tee /etc/hosts
echo "${config_data}" | sed 's/: / /g' | tr -d '{}' | tr ',' '\n' | tr -d ' ' | while read line; do
  ip=$(echo "${line}" | cut -d ' ' -f 1)
  hostname=$(echo "${line}" | cut -d ' ' -f 2)
  echo "${ip} ${hostname}" | tee -a /etc/hosts
done

# install time synchronization server
sudo apt update 
sudo apt-get install ntp
sudo apt-get install ntpdate
sudo ntpdate ntp.ubuntu.com

#Forwarding IPv4 and letting iptables see bridged traffic:

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# Disable swap
echo "[TASK 5] Disable SWAP"
sed -i '/swap/d' /etc/fstab
swapoff -a

#Add repository:

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
 "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
 "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
 sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

#Install Containerd:

sudo apt-get update
sudo apt-get install containerd.io


# Install apt-transport-https pkg
echo "[TASK 6] Installing apt-transport-https pkg"
apt-get update && apt-get sudo apt-get install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.26/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Configuring the systemd cgroup drive:
# Creating a containerd configuration file by executing the following command

sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/' /etc/containerd/config.toml

# Restart containerd

sudo systemctl restart containerd

# Update and install required packages on all the nodes:

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

# Add Kubernetes repository:

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update apt package index, install kubelet, kubeadm and kubectl, and pin their version:

sudo apt-get update
sudo apt-get install -y kubelet=1.26.1-00 kubectl=1.26.1-00 kubeadm=1.26.1-00
sudo apt-mark hold kubelet kubeadm kubectl

# create user kube for compliancy and add to sudoers
sudo useradd -md "/home/kube" -G sudo kube
sudo echo "kube:kube" | sudo chpasswd
sudo cp /home/vagrant/.bashrc /home/kube/.bashrc
sudo chown kube:kube /home/kube/.bashrc

# create alias for kubectl command
su - vagrant -c 'echo "alias k=kubectl" >> /home/vagrant/.bashrc'
su - kube -c 'echo "alias k=kubectl" >> /home/kube/.bashrc'
sleep 5


