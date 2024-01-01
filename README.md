<div align='center'>
<img src= "https://github.com/eli-pavlov/kubernetes-vagrant-EZ/blob/fda6bd8944a07a677f42d20ca32b5c597d0e9a22/docs/logo.webp" width=320 />
<h1>Vagrant Kubernetes EZ</h1>
 
<p> Easily deploy fully featured Kubernetes with Vagrant on a single machine</p>

<h4> <span> · </span> <a href="https://github.com/eli-pavlov/kubernetes-vagrant-EZ/blob/master/README.md"> Documentation </a> <span> · </span> <a href="https://github.com/eli-pavlov/helm-wordpress-mariadb/issues"> Report Bug </a> <span> · </span> <a href="https://github.com/eli-pavlov/kubernetes-vagrant-EZ/issues"> Request Feature </a> </h4>

$~~$
</div>

 :notebook_with_decorative_cover: Table of Contents

- [About the Project](#star2-about-the-project)
- [Prerequisites](#toolbox-getting-started)
- [Installation](#gear-installation)
- [Project Files](#open_file_folder-files)
- [License](#warning-license)
- [Contact](#handshake-contact)
- [Acknowledgements](#gem-acknowledgements)


$~~$


## :star2: About the Project
The purpose of this project is to deploy a fully functional Kubernetes cluster on a single machine, using VirtualBox and Vagrant.
Create a customized Kubernetes cluster within minutes, using one command only - "vagrant up".</br>
This is not a "minkube" or "light" Kubernetes - but a fully featured "Kubeadm" install.

After having to go through the process of creating Kubernetes clusters multiple times on my machine, I wanted to make the process as automated, streamlined and effortless as possible. While there are many Vagrant boxes and repos out there,
the majority are outdated, and I could not find a deployment which I could easily customize for my needs.

This release buids upon the work of - [hfmartinez/kubernetes-vagrant](https://github.com/hfmartinez/kubernetes-vagrant), [Innablr/K8s_ubuntu](https://github.com/Innablr/k8s_ubuntu), [exxsyseng/k8s_ubuntu](https://bitbucket.org/exxsyseng/k8s_ubuntu/src/master/) and others, bringing it up to date with latest OpenStack supported Kubernetes v.1.26, Ubuntu 22.04 LTS and expands with many additional options such as:

- Define any number of Worker nodes.
- Define any number of additional storage drives for Master/Worker nodes.
- Fully customized IP addreses and CIDR's.
- Choice of Kubernetes networking plugins: Flannel, Weave or Cillium [default].
- Option to Enable/Distable nested virtualization for guest VM's.
- Quality of life features like:</br>
   - Dynamic generation of guest VM's hosts file and hostnames.</br>
   - For CKA practice - Kube user, kubectl "k" alias, etc...
- All managed in a dynamic way from a single configuration file.

$~$
## :toolbox: Getting Started


### Prerequisites

1. **Check Virtualization is Enabled in BIOS:**
<img src= "https://github.com/eli-pavlov/kubernetes-vagrant-EZ/blob/master/docs/VT-x.jpg?raw=true" width=450 />

In AMD machines the feature is called SVM

<img src= "https://github.com/eli-pavlov/kubernetes-vagrant-EZ/blob/master/docs/SVM.jpg?raw=true" width=450 />

It is also a good practice to disable Windows HyperV when using VirtualBox:

<img src= "https://github.com/eli-pavlov/kubernetes-vagrant-EZ/blob/master/docs/HyperV.png" width=450 />

3. **Install VirtualBox**
```bash
https://www.virtualbox.org/wiki/Downloads
```
Verify there are 2 network adapters, "Host-Only" for internal communication,</br>
between the host machine and the cluster, and inter-cluster comms .</br>
And one for access to the internet - "NAT" adapter.</br>


"Host-Only" adapter's IP address should match the addresses defined in config.yaml file.</br>


Create "Host Only" Network adapter with ip adress of 192.168.10.1,</br>
DHCP server address 192.168.10.2 and address bound from 192.168.10.3</br>
to 192.168.10.254 The adapter with the cluster IP address should be at the top</br>
in the list because the top adapter is selected as main communications adapter for</br>
the cluster.

File -> Tools -> Network Manager -> Create

<img src= "https://github.com/eli-pavlov/vagrant-kubernetes-EZ/blob/c4c929065bdf0683f02b71d4a0b8678732035991/docs/adapter1a.JPG" width=450 /></br>


DHCP Server:</br>
<img src= "https://github.com/eli-pavlov/vagrant-kubernetes-EZ/blob/c4c929065bdf0683f02b71d4a0b8678732035991/docs/adapter1b.JPG" width=450 /></br>


Create "NAT" Network adapter with the name of "NatNetwork", and any IP address.</br>
<img src= "https://github.com/eli-pavlov/vagrant-kubernetes-EZ/blob/c4c929065bdf0683f02b71d4a0b8678732035991/docs/adaper2a.JPG" width=450 /></br>


3. **Install Vagrant**
```bash
https://developer.hashicorp.com/vagrant/install?product_intent=vagrant
```
4. **Install GIT**
```bash
https://git-scm.com/downloads
```
$~~~$

## :gear: Installation

1. **Clone this repository:**
```bash
git clone https://github.com/eli-pavlov/kubernetes-vagrant-EZ.git
```
2. **Review config.yaml file:**
```bash
vim config.yaml ##//(or edit using your editor of choice)//##
```
<img src= "https://github.com/eli-pavlov/kubernetes-vagrant-EZ/blob/7ba322e707c2e29eaf93f380c86f6a68677c6e51/docs/config.JPG" width=450 />

3. **Deploy the cluster:**
```bash
vagrant up
```
4. **Check cluster state:**
```bash
vagrant ssh master -c "kubectl get nodes -o wide"
```
5. **or SSH into the Master node by typing:**
```bash
vagrant ssh master
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
  -  Script to Install Master node specific packages and initialize the Kubernetes cluster.
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
