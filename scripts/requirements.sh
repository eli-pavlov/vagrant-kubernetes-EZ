#!/bin/bash

echo ""
echo "##################################"
echo "# RUNNING requirements.sh script #"
echo "##################################"
sleep 2
echo ""
echo ""


echo ""
echo "[TASK 1] update hosts file"
sudo cat /vagrant/scripts/hosts > /etc/hosts
echo "...done..."

# install time synchronization server
echo ""
echo "[TASK 2] install time synchronization server"
sudo apt update
sudo apt-get install ntp
sudo apt-get install ntpdate
sudo ntpdate ntp.ubuntu.com
echo "...done..."

# Forwarding IPv4 and letting iptables see bridged traffic:
echo ""
echo "[TASK 3] Forwarding IPv4 and letting iptables see bridged traffic"
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter
echo "...done..."

# sysctl params required by setup, params persist across reboots
echo ""
echo "[TASK 4] sysctl params required by setup, params persist across reboots"
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system
echo "...done..."

# Disable swap
echo ""
echo "[TASK 5] Disable swap"
sed -i '/swap/d' /etc/fstab
swapoff -a
echo "...done..."

# Add repository:
echo ""
echo "[TASK 6] Add repository"
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
 "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
 "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
 sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
echo "...done..."

# Install Containerd:
echo ""
echo "[TASK 7] Install Containerd"

sudo apt-get update
sudo apt-get install containerd.io

# Install apt-transport-https pkg
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
echo "...done..."

# Add Kubernetes repository:
echo ""
echo "[TASK 8] Install Kubernetes components"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update apt package index, install kubelet, kubeadm and kubectl, and pin their version:

sudo apt-get update
sudo apt-get install -y kubelet=1.26.1-00 kubectl=1.26.1-00 kubeadm=1.26.1-00
sudo apt-mark hold kubelet kubeadm kubectl
echo "...done..."


# create user kube for compliancy and add to sudoers
echo ""
echo "[TASK 9] create user kube for compliancy and add to sudoers"
sudo useradd -md "/home/kube" -G sudo kube
sudo echo "kube:kube" | sudo chpasswd
sudo cp /home/vagrant/.bashrc /home/kube/.bashrc
sudo chown kube:kube /home/kube/.bashrc
echo "...done..."


# create alias for kubectl command
echo ""
echo "[TASK 10] create alias for kubectl command"
su - vagrant -c 'echo "alias k=kubectl" >> /home/vagrant/.bashrc'
su - kube -c 'echo "alias k=kubectl" >> /home/kube/.bashrc'
echo "...done..."
sleep 5


