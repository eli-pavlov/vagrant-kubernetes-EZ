<div align='center'>

<img src= "https://github.com/eli-pavlov/helm-wordpress-mariadb/blob/master/docs/logo.png" width=300 />

<h1>Helm Wordpress chart</h1>
<p>A Helm chart for the deployment of "Wordpress" server with "MariaDB" database as a backend.</p>

<h4> <span> · </span> <a href="https://github.com/eli-pavlov/helm-wordpress-mariadb/blob/master/README.md"> Documentation </a> <span> · </span> <a href="https://github.com/eli-pavlov/helm-wordpress-mariadb/issues"> Report Bug </a> <span> · </span> <a href="https://github.com/eli-pavlov/helm-wordpress-mariadb/issues"> Request Feature </a> </h4>


</div>

# :notebook_with_decorative_cover: Table of Contents

- [About the Project](#star2-about-the-project)
- [License](#warning-license)
- [Contact](#handshake-contact)
- [Acknowledgements](#gem-acknowledgements)


## :star2: About the Project
The purpose of this project is to deploy a Wordpress server in the cloud as a microservice
in an easy and automated way. It is not intended to be used in production environment since 
many features like security, high availablity and scaling are absent in this release. 
However it is a perfect base for a start or as a personal project.


## Chart architecture

- **Chart.yaml:** Main chart file.
- **LICENSE.txt:** License file.
- **README.md:** Readme file formatted for Github, with information about the chart.
- **/docs:** Directory containing media files.
- **/templates:** Directory containing the chart templates. --> Press on the file names below for description.
  <details> <summary>mysql-storage-class.yaml:</summary> <ul>
  - Defining a storage class which will we will use for the creation and assignment of MySQL persistent volume.
  </ul> </details>
    <details> <summary>mysql-pv.yaml::</summary> <ul>
  -  Configuration file to create a Persistent Volume for MySQL to store the working directory in a persistent way.
  </ul> </details>
    <details> <summary>mysql-pvc.yaml:</summary> <ul>
  - Configuration file to create a Persistent Volume Claim for MySQL, to claim the created above Persistent Volume.
  </ul> </details>
    <details> <summary>mysql-configmap.yaml:</summary> <ul>
  - ConfigMap to define variables for MySQL deployment in a dynamic rather than a static way.
  </ul> </details>
    <details> <summary>mysql-deployment.yaml:</summary> <ul>
  - Main configuration file for the deployment of MySQL database as a micro-service in kubernetes.
  </ul> </details>
    <details> <summary>mysql-service.yaml:</summary>** <ul>
  - Configuration file to create a ClusterIP service for MySQL depoyment, so Wordpress can find it and connect to it.
  </ul> </details>

  ---
    **values.yaml:** Default configuration values for the Helm chart.

    **secret.yaml:** Configuration file for storing MySQL database password as a Kubernetes secret, the password is stored in Base64 format.

    **NOTES.txt:** File with instructions to be shown after deployment.

  ---
  <details> <summary>Wordpress-storage-class.yaml:</summary> <ul>
  - Defining a storage class which will we will use for the creation and assignment of Wordpress persistent volume.
  </ul> </details>
    <details> <summary>Wordpress-pv.yaml::</summary> <ul>
  -  Configuration file to create a Persistent Volume for Wordpress to store the working directory in a persistent way.
  </ul> </details>
    <details> <summary>Wordpress-pvc.yaml:</summary> <ul>
  - Configuration file to create a Persistent Volume Claim for Wordpress, to claim the created above Persistent Volume.
  </ul> </details>
    <details> <summary>Wordpress-configmap.yaml:</summary> <ul>
  - ConfigMap to define variables for Wordpress deployment in a dynamic rather than a static way.
  </ul> </details>
    <details> <summary>Wordpress-deployment.yaml:</summary> <ul>
  - Main configuration file for the deployment of Wordpress database as a micro-service in kubernetes.
  </ul> </details>
    <details> <summary>Wordpress-service.yaml:</summary>** <ul>
  - Configuration file to create a LoadBalancer service for internet access to Wordpress platform.
  </ul> </details>    
  


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

Project Link: [https://github.com/eli-pavlov/helm-wordpress-mariadb.git](https://github.com/eli-pavlov/helm-wordpress-mariadb.git)

## :gem: Acknowledgements

- [Kubernetes.io Documentation](https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/)
- [Helm Documentation](https://v3.helm.sh/docs/chart_template_guide/)
- [Wordpress](https://wordpress.com/)
- [MariaDB foundation](https://mariadb.org/)
- [Awesome Github Readme File Generator](https://www.genreadme.cloud/)
