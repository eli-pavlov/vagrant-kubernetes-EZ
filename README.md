<div align='center'>
<img src= "https://miro.medium.com/v2/resize:fit:720/format:webp/1*f1hLnqSswkvl8TVKMMjyFw.png" width=400 />

<h1>Vagrant Kubernetes EZ</h1>
<p>Easy deployment of Kubernetes with vagrant.</p>

<h4> <span> · </span> <a href="https://github.com/eli-pavlov/kubernetes-vagrant-EZ/blob/master/README.md"> Documentation </a> <span> · </span> <a href="https://github.com/eli-pavlov/helm-wordpress-mariadb/issues"> Report Bug </a> <span> · </span> <a href="https://github.com/eli-pavlov/kubernetes-vagrant-EZ/issues"> Request Feature </a> </h4>



</div>

# :notebook_with_decorative_cover: Table of Contents

- [About the Project](#star2-about-the-project)
- [License](#warning-license)
- [Contact](#handshake-contact)
- [Acknowledgements](#gem-acknowledgements)


## :star2: About the Project
The purpose of this project is 


## Project files

- **Vagrantfile:** Main deployment file.
- **config.yaml:** Main configuration file.
- **/scripts:** Directory containing the chart templates. --> Press on the file names below for description.
  <details> <summary>requirements.sh:</summary> <ul>
  - Script to install required packages on all VM's.
  </ul> </details>
    <details> <summary>master.sh:</summary> <ul>
  -  Configuration file to create a Persistent Volume for MySQL to store the working directory in a persistent way.
  </ul> </details>
    <details> <summary>worker.sh:</summary> <ul>
  - Configuration file to create a Persistent Volume Claim for MySQL, to claim the created above Persistent Volume.
  </ul> </details>
- **/docs:** Directory containing media files.
- **LICENSE.txt:** License file.
- **README.md:** Readme file formatted for Github, with information about the chart.

---

Notes:
1. All values for the configuration of the chart components are defined in the values.yaml file.
2. For this project 2GB of disk space were defined for each service, for actual use you would like to define 20GB or more.
3. The password for the database is Base64 encoded as a Kubernetes secret.



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
git clone https://github.com/eli-pavlov/helm-wordpress-mariadb.git
```
2. **Install the chart using "Helm":**
```bash
helm install wordpress helm-wordpress-mariadb
```

3. **Add an "A" record in the hosted zone pointing to "Alias" of the "wordpress" LoadBalancer service.**

4. **Login to "Wordpress" and create your website.**

5. **Enjoy!!!**

## :warning: License

Distributed under the Apache License 2.0 License.
Please note that this chart includes official WordPress and MariaDB images, which have their own respective licenses. 

WordPress: https://hub.docker.com/_/wordpress  
MariaDB: https://hub.docker.com/_/mariadb  

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
