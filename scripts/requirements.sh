#!/bin/bash
# Make `cmdA | cmdB` report failure if cmdA fails, not just cmdB - several
# steps below pipe a curl/containerd/etc. into gpg/tee, and a broken
# upstream fetch shouldn't be able to hide behind a downstream command that
# still exits 0.
set -o pipefail

echo ""
echo "##################################"
echo "# RUNNING requirements.sh script #"
echo "##################################"
sleep 2
echo ""
echo ""
echo ""
echo "[TASK 1] update hosts file"
sudo cp /tmp/scripts/hosts /etc/hosts
echo "...done..."

# install time synchronization server
echo ""
echo "[TASK 2] install time synchronization server"
sudo apt update
sudo apt-get install ntp -y
sudo apt-get install ntpdate -y
# Best-effort: the ntp package/daemon installed above already keeps time in
# sync, and this one-shot sync commonly fails with "port in use" if ntpd
# grabbed port 123 first. Not worth failing provisioning over.
sudo ntpdate ntp.ubuntu.com || echo "WARNING: ntpdate one-shot sync failed (non-fatal, ntp daemon is already running)"
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
sudo swapoff -a
echo "...done..."

# Add repository:
echo ""
echo "[TASK 6] Add repository"
sudo install -m 0755 -d /etc/apt/keyrings
if ! curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor | sudo tee /etc/apt/keyrings/docker.gpg > /dev/null; then
    echo "ERROR: failed to fetch/install the Docker apt signing key" >&2
    exit 1
fi
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
if ! sudo apt-get install containerd -y; then
    echo "ERROR: failed to install containerd" >&2
    exit 1
fi

# Install apt-transport-https pkg
if ! { sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl gpg; }; then
    echo "ERROR: failed to install apt-transport-https/ca-certificates/curl/gpg" >&2
    exit 1
fi

# Configuring the systemd cgroup drive:
# Creating a containerd configuration file by executing the following command
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/' /etc/containerd/config.toml

# Restart containerd

sudo systemctl restart containerd

# Add Kubernetes repository:
echo ""
echo "[TASK 8] Install Kubernetes components"
if ! curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.36/deb/Release.key | gpg --dearmor | sudo tee /etc/apt/keyrings/kubernetes-apt-keyring.gpg > /dev/null; then
    echo "ERROR: failed to fetch/install the Kubernetes apt signing key" >&2
    exit 1
fi
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.36/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update apt package index, install kubelet, kubeadm and kubectl, and pin their version:
sudo apt-get update
if ! sudo apt-get install -y kubelet=1.36.3-1.1 kubectl=1.36.3-1.1 kubeadm=1.36.3-1.1; then
    echo "ERROR: failed to install kubelet/kubectl/kubeadm 1.36.3-1.1 - check the pinned version is still available in the repo" >&2
    exit 1
fi
sudo apt-mark hold kubelet kubeadm kubectl
echo "...done..."

# create user kube for compliancy and add to sudoers
echo ""
echo "[TASK 9] create user kube for compliancy and add to sudoers"
sudo useradd -md "/home/kube" -G sudo kube
echo "kube:kube" | sudo chpasswd
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
