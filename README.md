<div align='center'>
<img src= "https://miro.medium.com/v2/resize:fit:720/format:webp/1*f1hLnqSswkvl8TVKMMjyFw.png" width=320 />
<h1>Vagrant Kubernetes EZ</h1>
 
<p>Easy deployment of Kubernetes with vagrant.</p>

<h4> <span> · </span> <a href="https://github.com/eli-pavlov/kubernetes-vagrant-EZ/blob/master/README.md"> Documentation </a> <span> · </span> <a href="https://github.com/eli-pavlov/helm-wordpress-mariadb/issues"> Report Bug </a> <span> · </span> <a href="https://github.com/eli-pavlov/kubernetes-vagrant-EZ/issues"> Request Feature </a> </h4>

$~~$

</div>

 :notebook_with_decorative_cover: Table of Contents

- [About the Project](#star2-about-the-project)
- [Prequisites](#space_invader-tech-stack)
- [Installation](#gear-installation)
- [License](#warning-license)
- [Contact](#handshake-contact)
- [Acknowledgements](#gem-acknowledgements)


## :star2: About the Project
The purpose of this project is do deploy a fully functional Kubernetes cluster on a single machine using VirtualBox and Vagrant, $~$ 
within minutes using with one command only - "vagrant up".

## Files

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

---

Default config.yaml configuration:
1. 4 CPU cores and 4GB RAM for Master, 2 CPU cores and 2GB RAM for worker nodes.
2. IP of master node is 192.168.10.100, worker nodes are 192.168.10.2...192.168.10.3, etc....
3. Nested Virtualization Vt-x/AMD-v Disabled.
4. No additional storage disks.

$~$
$~$

## :space_invader: Tech Stack
<details> <summary>VirtualBox</summary> <ul>
<li><a href="https://www.virtualbox.org">VirtualBox</a></li>
</ul> </details>
<details> <summary>Vagrant</summary> <ul>
<li><a href="https://www.vagrantup.com">Vagrant</a></li>
</ul> </details>
<details> <summary>Canonical Ubuntu</summary> <ul>
<li><a href="https://www.ubuntu.com">Canonical Ubuntu</a></li>
</ul> </details>
<details> <summary>Kubernetes</summary> <ul>
<li><a href="https://kubernetes.io">Kubernetes</a></li>
</ul> </details>

## :toolbox: Getting Started


### Prerequisites installed

1. **VirtualBox:**
```bash
https://www.virtualbox.org/wiki/Downloads
```
3. **Vagrant**
```bash
https://developer.hashicorp.com/vagrant/install?product_intent=vagrant
```
3. **GIT**
```bash
https://git-scm.com/downloads
```
$~~~$

## :gear: Installation

1. **Clone this repository:**
```bash
git clone https://github.com/eli-pavlov/kubernetes-vagrant-EZ.git
```
3. **Review config.yaml file**
```bash
vim config.yaml ##//(or edit using your editor of choice)//##
```
3. **Deploy the cluster:**
```bash
vagrant up
```
3. **Check cluster state:**
```bash
vagrant ssh master -c "kubectl get nodes -o wide"
```

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
