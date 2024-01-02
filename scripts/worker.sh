#!/bin/bash

# Join worker nodes to the Kubernetes cluster
echo ""
echo ""
echo "##################################"
echo "#   RUNNING worker.sh script     #"
echo "##################################"
sleep 2
echo ""
echo ""
echo "[TASK 1] Join node to Kubernetes Cluster"
bash /vagrant/scripts/joincluster.sh 2>/dev/null
echo "...done..."
echo ""
echo "===================================="
echo 'run command: vagrant ssh master -c "kubectl get nodes -o wide"'
echo 'or'
echo 'run command: "vagrant ssh master", to ssh into the master node'
echo 'or'
echo 'run command: "ssh vagrant@192.168.10.100 -i .vagrant/machines/master/virtualbox/private_key", to Login directly by providing vagrant generated private key.'
echo "===================================="
echo ""
