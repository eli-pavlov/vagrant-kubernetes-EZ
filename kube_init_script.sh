#!/bin/bash
echo "[TASK 1] Initialize Kubernetes Cluster"
sudo kubeadm init --apiserver-advertise-address=192.168.10.100 --pod-network-cidr=10.244.0.0/16 >> kubeinit.log 2>/dev/null
