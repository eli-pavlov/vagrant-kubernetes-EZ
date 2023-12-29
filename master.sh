#!/bin/bash

# Source network variables for kubeadm init command
API_SERVER_ADDRESS=$(grep 'master_ip' /vagrant/initial_setup.yaml | cut -d':' -f2 | tr -d ' ' | tr -d '"')
POD_NETWORK_CIDR=$(grep 'pod_network_cidr' /vagrant/initial_setup.yaml | cut -d':' -f2 | tr -d ' ' | tr -d '"')

# Debug information
echo "API_SERVER_ADDRESS: $API_SERVER_ADDRESS"
echo "POD_NETWORK_CIDR: $POD_NETWORK_CIDR"

# Initialize Kubernetes
echo "[TASK 1] Initialize Kubernetes Cluster"
# Since we use sudo, we need also to elevate the variables by using "-E" flag
sudo kubeadm init --apiserver-advertise-address="$API_SERVER_ADDRESS" --pod-network-cidr="$POD_NETWORK_CIDR"
sleep 30

# Generate Cluster join command
echo "[TASK 4] Generate and save cluster yjoin command to /vagrant/joincluster.sh"
sudo kubeadm token create --print-join-command > /vagrant/joincluster.sh 2>/dev/null

# Enable cluster control for users vagrant and kube without the need for sudo
echo "[TASK 2] Copy kube admin config to Vagrant user .kube directory"
mkdir -p /home/vagrant/.kube
mkdir -p /home/kube/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo cp -i /etc/kubernetes/admin.conf /home/kube/.kube/config
sudo chown vagrant:vagrant /home/vagrant/.kube/config
sudo chown kube:kube /home/kube/.kube/config

## OPTIONAL - Deploy flannel networking plugin, if chosen - disable Cilium below ##
# echo "[TASK 3] Deploy flannel network"
# kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

# Install Cilium network plugin
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
sudo curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sudo sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
sudo rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
export KUBECONFIG=/home/vagrant/.kube/config
su - vagrant -c "cilium install --version 1.14.5"
echo "alias k=kubectl" >> /home/vagrant/.bashrc