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
<details> <summary>Kubernetes</summary> <ul>
<li><a href="https://kubernetes.io">Kubernetes</a></li>
</ul> </details>

## :toolbox: Getting Started

### :bangbang: Prerequisites

- AWS or any other cloud based Kubernetes cluster with "Helm" installed.
- Git installed (sudo apt/yum/dnf install git).
- Hosted zone in "Route53" or any other domain manager, with a domain or a sub.domain defined for Wordpress server.


## :gear: Installation

1. **Clone the repo:**
```bash
git clone https://github.com/eli-pavlov/kubernetes-vagrant-EZ.git
```
3. **Verify settings in config.yaml file**
2. **Install the chart using "Helm":**
```bash
vagrant up
```

3. **Add an "A" record in the hosted zone pointing to "Alias" of the "wordpress" LoadBalancer service.**
$~~$

## :warning: License

Distributed under the Apache License 2.0 License.

Please note that Kubernetes VirtualBox and Vagrant have their own respective licenses. 

See LICENSE.txt for more information.
$~$

## :handshake: Contact

Eli Pavlov - www.weblightenment.com - admin@weblightenment.com

Project Link: https://github.com/eli-pavlov/kubernetes-vagrant-EZ.git
$~$

## :gem: Acknowledgements

- [Kubernetes.io Documentation](https://kubernetes.io/docs)
- [Oracle VirtualBox](https://www.virtualbox.org)
- [HashiCorp Vagrant](https://www.vagrantup.com)
- [hfmartinez/kubernetes-vagrant](https://github.com/hfmartinez/kubernetes-vagrant)
- [Innablr/K8s_ubuntu](https://github.com/Innablr/k8s_ubuntu)
- [exxsyseng/k8s_ubuntu](https://bitbucket.org/exxsyseng/k8s_ubuntu/src/master/)
- [Awesome Github Readme File Generator](https://www.genreadme.cloud/)
