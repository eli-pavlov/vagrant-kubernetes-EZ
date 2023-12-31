<div align='center'>

<h1>Vagrant Kubernetes EZ</h1>
<img src= "https://miro.medium.com/v2/resize:fit:720/format:webp/1*f1hLnqSswkvl8TVKMMjyFw.png" width=320 />

<p>Easy deployment of Kubernetes with vagrant.</p>

<h4> <span> · </span> <a href="https://github.com/eli-pavlov/kubernetes-vagrant-EZ/blob/master/README.md"> Documentation </a> <span> · </span> <a href="https://github.com/eli-pavlov/helm-wordpress-mariadb/issues"> Report Bug </a> <span> · </span> <a href="https://github.com/eli-pavlov/kubernetes-vagrant-EZ/issues"> Request Feature </a> </h4>



</div>

# :notebook_with_decorative_cover: Table of Contents

- [About the Project](#star2-about-the-project)
- [License](#warning-license)
- [Contact](#handshake-contact)
- [Acknowledgements](#gem-acknowledgements)
$~~~$

## :star2: About the Project
The purpose of this project is 


## Project map

- **Vagrantfile:** Main deployment file.
- **config.yaml:** Main configuration file.
- **/scripts:** Directory containing the chart templates. --> Press on the file names below for description.


  
  <details> <summary>requirements.sh:</summary> <ul>
  - Script to install required packages on all VM's.
  </ul> </details>
    <details> <summary>master.sh:</summary> <ul>
  -  Script to Install Master node specific packages and deploy Kubernetes cluster.
  </ul> </details>
    <details> <summary>worker.sh:</summary> <ul>
  - Script to join worker nodes to the cluster.
  </ul> </details>
- **/docs:** Directory containing media files.
- **LICENSE.txt:** License file.
- **README.md:** Readme file formatted for Github, with information about the chart.

---

Notes:
1. All values for the configuration of the chart components are defined in the config.yaml file.
2. The default config is 4 CPU cores and 4GB RAM for Master, 2 CPU cores and 2GB RAM for worker nodes.

$~$
$~$

### :space_invader: Tech Stack
<details> <summary>Client</summary> <ul>
<li><a href="https://wordpress.com/he/">WordPress</a></li>
</ul> </details>
<details> <summary>Server</summary> <ul>
<li><a href="https://httpd.apache.org/">Apache</a></li>
</ul> </details>
<details> <summary>Database</summary> <ul>
<li><a href="https://mariadb.org/">MariaDB</a></li>
</ul> </details>

## :toolbox: Getting Started

### :bangbang: Prerequisites

- AWS or any other cloud based Kubernetes cluster with "Helm" installed.
- Git installed (sudo apt/yum/dnf install git).
- Hosted zone in "Route53" or any other domain manager, with a domain or a sub.domain defined for Wordpress server.


### :gear: Installation

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


## :warning: License

Distributed under the Apache License 2.0 License.

Please note that Kubernetes and Vagrant have their own respective licenses. 

See LICENSE.txt for more information.

## :handshake: Contact

Eli Pavlov - www.weblightenment.com - admin@weblightenment.com

Project Link: https://github.com/eli-pavlov/kubernetes-vagrant-EZ.git

## :gem: Acknowledgements

- [Kubernetes.io Documentation](https://kubernetes.io/docs)
- [HashiCorp Vagrant](https://www.vagrantup.com/)
- [hfmartinez/kubernetes-vagrant](https://github.com/hfmartinez/kubernetes-vagrant)
- [Innablr/K8s_ubuntu](https://github.com/Innablr/k8s_ubuntu)
- [exxsyseng/k8s_ubuntu](https://bitbucket.org/exxsyseng/k8s_ubuntu/src/master/)
- [Awesome Github Readme File Generator](https://www.genreadme.cloud/)
