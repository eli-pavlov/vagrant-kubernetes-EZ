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

# The /vagrant shared folder can take a few seconds to mount after boot, and
# on a VirtualBox/Guest-Additions version mismatch (older GA baked into the
# box vs. a newer VirtualBox host) it can fail to mount at all. That
# previously caused this step to silently no-op - the join script simply
# wasn't there to read - while still reporting "...done...", leaving the
# node out of the cluster with no visible error. Wait for it to appear, and
# fail the provisioner loudly if it never does or if the join itself fails.
JOIN_SCRIPT="/vagrant/scripts/joincluster.sh"
ATTEMPTS=0
MAX_ATTEMPTS=30
until [ -s "$JOIN_SCRIPT" ] || [ "$ATTEMPTS" -ge "$MAX_ATTEMPTS" ]; do
    ATTEMPTS=$((ATTEMPTS + 1))
    echo "Waiting for $JOIN_SCRIPT (shared folder mount / master provisioning)... attempt $ATTEMPTS/$MAX_ATTEMPTS"
    sleep 5
done

if [ ! -s "$JOIN_SCRIPT" ]; then
    echo "ERROR: $JOIN_SCRIPT never appeared." >&2
    echo "Check that the /vagrant shared folder is mounted on this VM ('mount | grep vagrant')" >&2
    echo "and that the master node finished provisioning successfully." >&2
    exit 1
fi

if ! bash "$JOIN_SCRIPT"; then
    echo "ERROR: kubeadm join failed - see output above." >&2
    exit 1
fi
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
