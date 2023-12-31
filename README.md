<div align='center'>
<img src= "https://github.com/eli-pavlov/kubernetes-vagrant-EZ/blob/fda6bd8944a07a677f42d20ca32b5c597d0e9a22/docs/logo.webp" width=320 />
<h1>Vagrant Kuberentes EZ</h1>
 
<p> Easily deploy fully featured Kubernetes with Vagrant</p>

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
The purpose of this project is to deploy a fully functional Kubernetes cluster on a single machine, using VirtualBox and Vagrant.</br>
Create a customized Kubernetes cluster within minutes, using one command only - "vagrant up".</br>
This is not a "minkube" or "light" Kubernetes - but a fully featured "Kubeadm" install.

After having to go through the process of creating Kubernetes clusters multiple times on my machine, I wanted to make </br> the process as automated, streamlined and effortless as possible. While there are many Vagrant boxes and repos out there,</br>
the majority are outdated, and I could not find a deployment which I could easily customize for my needs.

This release buids upon the work of - [hfmartinez/kubernetes-vagrant](https://github.com/hfmartinez/kubernetes-vagrant), [Innablr/K8s_ubuntu](https://github.com/Innablr/k8s_ubuntu), [exxsyseng/k8s_ubuntu](https://bitbucket.org/exxsyseng/k8s_ubuntu/src/master/) and others,</br>Bringing it up to date with latest OpenStack supported Kubernetes v.1.26, Ubuntu 22.04 LTS and expands with many additional options such as:

- Define any number of Worker nodes.
- Define any number of additional storage drives for Master/Worker nodes.
- Fully customized IP addreses and CIDR's.
- Choice of Kubernetes networking plugins: Flannel, Weave or Cillium [default].
- Option to Enable/Distable nested virtualization for guest VM's.
- All managed in a dynamic way from a single configuration file.

$~$
## :toolbox: Getting Started


### Prerequisites

1. **Check Virtualization is Enabled in BIOS:**
<img src= "https://github.com/eli-pavlov/kubernetes-vagrant-EZ/blob/master/docs/VT-x.jpg?raw=true" width=320 />

In AMD machines the feature is called SVM

<img src= "https://github.com/eli-pavlov/kubernetes-vagrant-EZ/blob/master/docs/SVM.jpg?raw=true" width=320 />

It is also a good practice to disable Windows HyperV when using VirtualBox:

<img src= "https://github.com/eli-pavlov/kubernetes-vagrant-EZ/blob/master/docs/HyperV.png" width=320 />

3. **Install VirtualBox**
```bash
https://www.virtualbox.org/wiki/Downloads
```
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
3. **Review config.yaml file:**
```bash
vim config.yaml ##//(or edit using your editor of choice)//##
```
<img src= "https://github.com/eli-pavlov/kubernetes-vagrant-EZ/blob/7ba322e707c2e29eaf93f380c86f6a68677c6e51/docs/config.JPG" width=320 />

3. **Deploy the cluster:**
```bash
vagrant up
```
3. **Check cluster state:**
```bash
vagrant ssh master -c "kubectl get nodes -o wide"
```

$~$


## :open_file_folder: Files

- **Vagrantfile:** Main deployment file.
- **config.yaml:** Main configuration file.
- **/scripts:** Directory containing the chart templates. --> Press on the file names below for description.


  
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

Project Link: https://github.com/eli-pavlov/kubernetes-vagrant-EZ.git
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
