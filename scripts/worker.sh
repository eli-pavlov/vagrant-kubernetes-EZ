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
echo "===================================="
echo ""
