#!/bin/bash

# Execute kubeadm init script
echo ""
echo ""
echo "##################################"
echo "#   RUNNING master.sh script     #"
echo "##################################"
sleep 2
echo ""
echo ""
sudo bash /tmp/scripts/kube_init_script.sh
if [ $? -ne 0 ]; then
    echo "ERROR: kubeadm init failed. Last 40 lines of kubeinit.log:" >&2
    tail -n 40 kubeinit.log >&2
    exit 1
fi
echo "...done..."

# Generate Cluster join command
echo ""
echo "[TASK 2] Generate and save cluster join command to /vagrant/scripts/joincluster.sh"
if ! sudo kubeadm token create --print-join-command > /vagrant/scripts/joincluster.sh; then
    echo "ERROR: failed to write /vagrant/scripts/joincluster.sh - is the /vagrant shared folder mounted on this VM?" >&2
    exit 1
fi
if [ ! -s /vagrant/scripts/joincluster.sh ]; then
    echo "ERROR: /vagrant/scripts/joincluster.sh is empty after generation" >&2
    exit 1
fi
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

echo "[TASK 4] Install Pod Networking plugin"
pod_network_plugin=$(grep "pod_network_plugin" /vagrant/config.yaml | awk '{print $2}')
echo "$pod_network_plugin Networking plugin selected"
if [ "$pod_network_plugin" == "Flannel" ]; then
    echo "Installing Flannel network plugin"
    if ! su - vagrant -c "kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml"; then
        echo "ERROR: failed to apply Flannel manifest" >&2
        exit 1
    fi
elif [ "$pod_network_plugin" == "Weave" ]; then
    # weaveworks/weave was archived in June 2024; v2.8.1 is the final release, kept for compatibility only.
    echo "Installing Weave network plugin"
    if ! su - vagrant -c "kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml"; then
        echo "ERROR: failed to apply Weave manifest" >&2
        exit 1
    fi
elif [ "$pod_network_plugin" == "Calico" ]; then
    echo "Installing Calico network plugin"
    su - vagrant -c "kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.32.1/manifests/tigera-operator.yaml"
    # The tigera-operator registers its own CRDs (Installation, APIServer, ...) on
    # startup rather than shipping them in tigera-operator.yaml. Applying
    # custom-resources.yaml immediately races the operator pod and fails with
    # "no matches for kind ... ensure CRDs are installed first". Wait for the
    # operator deployment, then poll for the CRDs to actually exist (a single
    # `kubectl wait` on a CRD that isn't registered yet errors immediately
    # instead of waiting for it to appear) before applying custom resources.
    echo "Waiting for Tigera operator to be ready"
    if ! su - vagrant -c "kubectl -n tigera-operator wait --for=condition=Available --timeout=180s deployment/tigera-operator"; then
        echo "ERROR: tigera-operator deployment never became Available" >&2
        exit 1
    fi

    echo "Waiting for Tigera CRDs to be registered"
    CRD_ATTEMPTS=0
    until su - vagrant -c "kubectl get crd installations.operator.tigera.io apiservers.operator.tigera.io" >/dev/null 2>&1 || [ "$CRD_ATTEMPTS" -ge 24 ]; do
        CRD_ATTEMPTS=$((CRD_ATTEMPTS + 1))
        sleep 5
    done
    if ! su - vagrant -c "kubectl wait --for=condition=Established --timeout=60s crd/installations.operator.tigera.io crd/apiservers.operator.tigera.io"; then
        echo "ERROR: Tigera CRDs never reached Established" >&2
        exit 1
    fi

    # Retry the apply itself too (kubectl apply is idempotent, unlike create)
    # in case of a lingering propagation delay between the CRD being
    # Established and the API server actually accepting instances of it.
    echo "Applying Calico custom resources"
    APPLY_ATTEMPTS=0
    until su - vagrant -c "kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.32.1/manifests/custom-resources.yaml"; do
        APPLY_ATTEMPTS=$((APPLY_ATTEMPTS + 1))
        if [ "$APPLY_ATTEMPTS" -ge 6 ]; then
            echo "ERROR: failed to apply Calico custom-resources.yaml after $APPLY_ATTEMPTS attempts" >&2
            exit 1
        fi
        echo "Retrying Calico custom-resources.yaml apply ($APPLY_ATTEMPTS/6)..."
        sleep 10
    done
elif [ "$pod_network_plugin" == "Cilium" ]; then
    echo "Installing Cilium networking plugin"
    CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
    if [ -z "$CILIUM_CLI_VERSION" ]; then
        echo "ERROR: failed to resolve latest Cilium CLI version" >&2
        exit 1
    fi
    CLI_ARCH=amd64
    if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
    if ! curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}; then
        echo "ERROR: failed to download Cilium CLI" >&2
        exit 1
    fi
    if ! sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum; then
        echo "ERROR: Cilium CLI checksum verification failed" >&2
        exit 1
    fi
    if ! sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin; then
        echo "ERROR: failed to extract Cilium CLI" >&2
        exit 1
    fi
    rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
    export KUBECONFIG=/home/vagrant/.kube/config
    if ! su - vagrant -c "cilium install --version 1.20.0"; then
        echo "ERROR: cilium install failed" >&2
        exit 1
    fi
else
    echo "Unknown pod network plugin specified in config file"
fi
echo "...done..."
echo "##################################"
echo "#   MASTER NODE SETUP COMPLETE   #"
echo "##################################"
echo ""
echo ""
