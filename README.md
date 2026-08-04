<div align='center'>
<img src= "https://github.com/eli-pavlov/kubernetes-vagrant-EZ/blob/fda6bd8944a07a677f42d20ca32b5c597d0e9a22/docs/logo.webp" width=320 />
<h1>Vagrant Kubernetes EZ</h1>
 
<p>  Deploy a fully featured Kubernetes cluster on your machine? That's EZ! </p>

<h4> <span> · </span> <a href="https://github.com/eli-pavlov/kubernetes-vagrant-EZ/blob/master/README.md"> Documentation </a> <span> · </span> <a href="https://github.com/eli-pavlov/helm-wordpress-mariadb/issues"> Report Bug </a> <span> · </span> <a href="https://github.com/eli-pavlov/kubernetes-vagrant-EZ/issues"> Request Feature </a> </h4>

$~~$
</div>

 :notebook_with_decorative_cover: Table of Contents

- [About the Project](#star2-about-the-project)
- [Changelog](#memo-changelog)
- [TL;DR](#rocket-tldr)
- [Prerequisites](#toolbox-getting-started)
- [Installation](#gear-installation)
- [Project Files](#open_file_folder-files)
- [License](#warning-license)
- [Contact](#handshake-contact)
- [Acknowledgements](#gem-acknowledgements)


$~~$


## :star2: About the Project

The purpose of this project is to deploy a fully functional Kubernetes cluster on a single machine within minutes, using one command only - "vagrant up".
Not a "minkube" or "light" Kubernetes - but a fully featured "Kubeadm" install deployed on Linux Ubuntu 22.04.</br>

Vagrant doesn't just deploy the Kubernetes cluster - it provides, configures and manages all the underlaying infrastructure.
Making possible to build and re-build whole systems in minutes. This makes simulation of complex environments on just one machine a breeze.

This release buids upon the work of - [hfmartinez/kubernetes-vagrant](https://github.com/hfmartinez/kubernetes-vagrant), [Innablr/K8s_ubuntu](https://github.com/Innablr/k8s_ubuntu), [exxsyseng/k8s_ubuntu](https://bitbucket.org/exxsyseng/k8s_ubuntu/src/master/) and others, brings it up to date with Kubernetes v1.36, Ubuntu 22.04 LTS and expands with many additional options such as:

- Define any number of Worker nodes.
- Define any number of additional storage drives for Master/Worker nodes.
- Fully customized IP addreses and CIDR's.
- Choice of Kubernetes networking plugins: Flannel, Weave, Calico [default] or Cilium.
- Option to Enable/Distable nested virtualization for guest VM's.
- Quality of life features like:</br>
   - Dynamic generation of guest VM's hosts file and hostnames.</br>
   - For CKA practice - Kube user, kubectl "k" alias, etc...
- All managed in a dynamic way from a single configuration file.

$~~$

This is not a PRODUCTION SETUP, it's aim is to simulate a full scale single machine/multi-node cluster for development and studies.

$~$

## :memo: Changelog

Notable updates made mid-lifecycle to keep the project current and the deployment reliable:

#### 2026-08-04 — Deployment quality improvements (round 2)

A from-scratch `vagrant destroy && vagrant up` still hit two silent failures despite round 1 below, tracked down to a wider pattern in `scripts/master.sh` / `scripts/worker.sh`: several steps redirected `stderr` to `/dev/null` and unconditionally printed `"...done..."` regardless of whether the preceding command actually succeeded, so `vagrant up` reported success while the cluster was actually broken.

- `scripts/worker.sh`: the join step read `/vagrant/scripts/joincluster.sh` with `2>/dev/null` and no existence check. On a node where the `/vagrant` shared folder failed to mount (see the `vagrant-vbguest` note in [Prerequisites](#toolbox-getting-started)), that file simply wasn't there — the redirect swallowed the resulting error, `kubeadm join` never ran, and the script still printed `"...done..."`. The node stayed out of the cluster with no indication anything had gone wrong; only `kubectl get nodes` showing it missing gave it away. Now waits (up to 2.5 min) for the file to appear and `exit 1`s with a clear message if it never does or if `kubeadm join` itself fails.
- `scripts/master.sh`: `kubeadm init`'s exit code was never checked, and the join-command generation (`kubeadm token create --print-join-command > /vagrant/scripts/joincluster.sh`) also redirected stderr to `/dev/null` with no check that the file actually got written. Both now fail the provisioner loudly instead of silently continuing.
- `scripts/master.sh` Calico step: round 1's fix (see below) added a single `kubectl wait --for=condition=Established` call, but a rebuild still reproduced the original race — `kubectl create -f custom-resources.yaml` failed with `ensure CRDs are installed first` again, with no trace of the wait command's own output in the log, root cause undetermined. Replaced with a poll loop that confirms the CRDs exist before waiting on them, `exit 1`s if the operator/CRDs never come up, and retries the (now `apply` instead of `create`, so it's idempotent) custom-resources apply up to 6 times.
- `Vagrantfile`: the generated `kube_init_script.sh` redirected `kubeadm init`'s stderr to `/dev/null` too, so even the newly-added exit-code check in `master.sh` had nothing to show for a failure. Now keeps stderr in `kubeinit.log` alongside stdout.
- Recommended installing the `vagrant-vbguest` plugin (see [Prerequisites](#toolbox-getting-started)) to keep Guest Additions in sync with the host's VirtualBox version — the actual root cause of the shared-folder mount failure above, rather than just the error handling around it.
- Bumped default `memory` for master and worker nodes in `config.yaml` from 2048MB to 6144MB. 2GB was tight enough for a full kubeadm control-plane (etcd + API server + scheduler + controller-manager + kubelet + containerd + Calico) that the master node became unresponsive to SSH under load during testing.

#### 2026-08-04 — Deployment quality improvements (round 1)

- Fixed a race condition in the Calico install step: the tigera-operator registers its own CRDs (`Installation`, `APIServer`, ...) on startup rather than shipping them in `tigera-operator.yaml`, so applying `custom-resources.yaml` immediately after could fail with `ensure CRDs are installed first`, leaving nodes stuck `NotReady` with no pod network. `scripts/master.sh` now waits for the operator deployment and its CRDs to be ready before applying custom resources.
- Increased `Vagrantfile`'s `config.vm.boot_timeout` from 600s to 900s to give more headroom against transient host stalls (e.g. antivirus scanning VM disk files) during guest boot.
- Documented excluding the VirtualBox VMs folder from Windows Defender/antivirus scanning (see [Prerequisites](#toolbox-getting-started)) — the most common cause of a guest appearing to hang mid-boot on Windows hosts.

#### 2026-08-03 — Version bump

- Kubernetes: v1.32.1 → **v1.36.3**
- Calico: v3.27.0 → **v3.32.1**, and promoted to the **default** pod network plugin
- Cilium CLI: v1.14.5 → **v1.20.0**
- Weave: upstream project archived (June 2024); kept in `master.sh` only for backward compatibility and no longer recommended
- Minor script robustness fixes (host file copy, removed a duplicate Kubernetes signing-key download)

#### 2025-09 — Calico networking added

- Added Calico as a selectable (and eventually default) pod network plugin alongside Flannel, Weave and Cilium.

$~$


## :rocket: TL;DR


- [**Install VirtualBox**](https://www.virtualbox.org/wiki/Downloads) - and add/configure the top-most "Host-Only" Network Interface with ip 192.168.56.1

- [**Install Vagrant**](https://developer.hashicorp.com/vagrant/install?product_intent=vagrant)   - and add vagrant to vboxusers group (on Linux only).
```bash
sudo usermod -aG vboxusers vagrant
```

- [**Install GIT**](https://git-scm.com/downloads)

  
$~~$


1. **Clone this repository:**
```bash
git clone https://github.com/eli-pavlov/vagrant-kubernetes-EZ.git
```
2. **Enter the project directory:**
```bash
cd vagrant-kubernetes-EZ
```
3. **Review config.yaml file:**
```bash
vim config.yaml ##//(or edit using your editor of choice)//##
```
4. **Deploy the cluster:**
```bash
vagrant up
```
5. **Check cluster state:**
```bash
vagrant ssh master -c "kubectl get nodes -o wide"
```
6. **SSH (connect) to Master node by typing:**
```bash
vagrant ssh master
```
or
```bash
ssh vagrant@192.168.56.100 -i .vagrant/machines/master/virtualbox/private_key #Login directly by providing vagrant generated private key.
```
The location of the private key of the master node on the host machine is : <PROJECT_FOLDER>/.vagrant/machines/master/virtualbox/private_key</br>


or

---> **Login directly to VirtualBox VM:** <---</br>
Username: "vagrant"</br>
password: "vagrant"</br>

7. **To delete the cluster and revert any changes made to host machine:**
```bash
vagrant destroy -f
```

$~$

## :toolbox: Getting Started


### Prerequisites

- VirtualBox with 2 virtual network adapters
- Vagrant
- GIT

---

1. **Check Virtualization is Enabled in BIOS:**
<img src= "https://github.com/eli-pavlov/kubernetes-vagrant-EZ/blob/master/docs/VT-x.jpg?raw=true" width=450 />

In AMD machines the feature is called SVM

<img src= "https://github.com/eli-pavlov/kubernetes-vagrant-EZ/blob/master/docs/SVM.jpg?raw=true" width=450 />

It is also a good practice to disable Windows HyperV when using VirtualBox:

<img src= "https://github.com/eli-pavlov/kubernetes-vagrant-EZ/blob/master/docs/HyperV.png" width=450 />

On Windows hosts, also add an exclusion for the VirtualBox VMs folder (default: `%USERPROFILE%\VirtualBox VMs`) in Windows Defender / your antivirus. Real-time scanning of VM disk files while a guest is booting is a common cause of a VM appearing to hang or timing out during `vagrant up`.

Install the [`vagrant-vbguest`](https://github.com/dotless-de/vagrant-vbguest) plugin so the box's Guest Additions get kept in sync with your VirtualBox version:
```bash
vagrant plugin install vagrant-vbguest
```
The `ubuntu/jammy64` box ships an old Guest Additions build; if it drifts far enough behind your host's VirtualBox version, the `/vagrant` shared folder can fail to mount on a given node (silently, with no error at the point of failure) - which then makes that node's join-cluster step read a join script that was never delivered. `vagrant-vbguest` auto-updates Guest Additions on `vagrant up`/`reload`, which is the actual fix; the error handling described below is a safety net for if it's still not installed.

2. **[Install VirtualBox](https://www.virtualbox.org/wiki/Downloads)**


Verify there are at least 2 virtual network adapters defined in VirtualBox, "Host-Only" adapter for host and cluster</br> internal communication.
And "NAT" adapter for access to the internet.</br>


Configure the top-most "Host Only" Network adapter with ip adress of 192.168.56.1,</br>
DHCP server address 192.168.56.2 and address boundaries from 192.168.56.3</br>
to 192.168.56.254.</br>


The adapter with the cluster IP address should be at the top of the list,</br>
because the top adapter is always selected as the main Network adapter for
the VM. </br>


IMPORTANT! "Host-Only" adapter's IP address should always match the addresses defined in config.yaml file.</br>


File -> Tools -> Network Manager -> Create

<img src= "https://github.com/eli-pavlov/vagrant-kubernetes-EZ/blob/d1b8c9468f95080cac2df5eee298cf49dd341e3f/docs/adapter1a.JPG" width=450 /></br>


Configure DHCP Server of "Host-Only" adapter:</br>
<img src= "https://github.com/eli-pavlov/vagrant-kubernetes-EZ/blob/d1b8c9468f95080cac2df5eee298cf49dd341e3f/docs/adapter1b.JPG" width=450 /></br>


Check NAT network adapter is present:</br>
<img src= "https://github.com/eli-pavlov/vagrant-kubernetes-EZ/blob/c4c929065bdf0683f02b71d4a0b8678732035991/docs/adaper2a.JPG" width=450 /></br>


3. **[Install Vagrant](https://developer.hashicorp.com/vagrant/install?product_intent=vagrant)**   - and add vagrant to vboxusers group (on Linux only).
```bash
sudo usermod -aG vboxusers vagrant
```
4. **Install GIT**
```bash
https://git-scm.com/downloads
```
$~~~$

## :gear: Installation

1. **Clone this repository:**
```bash
git clone https://github.com/eli-pavlov/vagrant-kubernetes-EZ.git
```
2. **Enter the project directory:**
```bash
cd vagrant-kubernetes-EZ
```
3. **Review config.yaml file:**
```bash
vim config.yaml ##//(or edit using your editor of choice)//##
```
<img src= "https://github.com/eli-pavlov/vagrant-kubernetes-EZ/blob/8cf5b26f787141be6011be61af5a801330434e35/docs/config.JPG" width=450 />

4. **Deploy the cluster:**
```bash
vagrant up
```
5. **Check cluster state:**
```bash
vagrant ssh master -c "kubectl get nodes -o wide"
```
6. **SSH (connect) to the Master node by typing:**
```bash
vagrant ssh master
```
or
```bash
ssh vagrant@192.168.56.100 -i .vagrant/machines/master/virtualbox/private_key #Login directly by providing vagrant generated private key.
```
The location of the private key of the master node on the host machine is : <PROJECT_FOLDER>/.vagrant/machines/master/virtualbox/private_key</br>


or

---> **Login directly to VirtualBox VM:** <---</br>
Username: "vagrant"</br>
password: "vagrant"</br>

$~$

7. **To delete the cluster and revert any changes made to host machine:**
```bash
vagrant destroy -f
```
$~$


## :open_file_folder: Files

- **Vagrantfile:** Main deployment file.
- **config.yaml:** Main configuration file.
- **/scripts:** Directory containing scripts and dynamically generated files. --> Press on the file names below for description.


  
  <details> <summary>requirements.sh:</summary> <ul>
  - Script to install required packages on all VM's.
  </ul> </details>
    <details> <summary>master.sh:</summary> <ul>
  -  Script to Install Master node specific packages, initialize the Kubernetes cluster and install the selected pod network plugin (waiting for the CNI operator's CRDs to be ready first, where applicable).
  </ul> </details>
    <details> <summary>worker.sh:</summary> <ul>
  - Script to join worker nodes to the cluster.
  </ul> </details>
- **/docs:** Directory containing media files.
- **LICENSE.txt:** License file.
- **README.md:** Readme file formatted for Github, with information about the chart.


$~$


## :warning: License

Distributed under the Apache License 2.0 License.

Please note that Kubernetes VirtualBox and Vagrant have their own respective licenses. 

See LICENSE.txt for more information.
$~$

## :handshake: Contact

Eli Pavlov - www.weblightenment.com - admin@weblightenment.com

Project Link: https://github.com/eli-pavlov/vagrant-kubernetes-EZ.git
$~$

## :gem: Acknowledgements and thanks to:
- [Canonical Ubuntu](https://ubuntu.com/community/governance/canonical)
- [Kubernetes.io](https://kubernetes.io/docs)
- [Oracle VirtualBox](https://www.virtualbox.org)
- [HashiCorp Vagrant](https://www.vagrantup.com)
- [hfmartinez/kubernetes-vagrant](https://github.com/hfmartinez/kubernetes-vagrant)
- [Innablr/K8s_ubuntu](https://github.com/Innablr/k8s_ubuntu)
- [exxsyseng/k8s_ubuntu](https://bitbucket.org/exxsyseng/k8s_ubuntu/src/master/)
- [Awesome Github Readme File Generator](https://www.genreadme.cloud/)
