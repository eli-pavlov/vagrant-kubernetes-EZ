#!/bin/bash

# Execute kubeadm init script
echo ""
echo ""
echo "##################################"
echo "# RUNNING master.sh script       #"     
echo "##################################"
sleep 2
echo ""
echo ""
sudo bash /tmp/kube_init_script.sh
echo "...done..."

# Generate Cluster join command
echo ""
echo "[TASK 2] Generate and save cluster yjoin command to /vagrant/scripts/joincluster.sh"
sudo kubeadm token create --print-join-command > /vagrant/scripts/joincluster.sh 2>/dev/null
echo "...done..."

# Enable cluster control for users vagrant and kube, without the need for sudo
echo ""
echo "[TASK 3] Copy kube admin config to user's .kube directory"
mkdir -p /home/vagrant/.kube
mkdir -p /home/kube/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo cp -i /etc/kubernetes/admin.conf /home/kube/.kube/config
sudo chown vagrant:vagrant /home/vagrant/.kube/config
sudo chown kube:kube /home/kube/.kube/config
echo "...done..."

## OPTIONAL - Deploy flannel networking plugin, if chosen - disable Cilium below ##
# echo "[TASK 6] Deploy flannel network"
# kubectl app-Ely -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

### Install Cilium networking plugin ###
echo ""
echo "[TASK 4] Install Cilium Networking plugin"
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
sudo curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sudo sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
sudo rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
export KUBECONFIG=/home/vagrant/.kube/config
su - vagrant -c "cilium install --version 1.14.5"
echo "...done..."