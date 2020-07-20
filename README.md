# Catalog Receptor Installer Scripts

This repository consists of scripts that can be used to install and configure

 Receptor & 
 Catalog Receptor Plugin

This would allow your on premise Ansible Tower to connect to cloud.redhat.com

The Receptor & the catalog Receptor plugin can be installed on one of the following

 - Container
 - VM
 - Physical 

**Pre Requisites**

 - RHEL 7 or
 - RHEL 8
  
 With valid subscriptions.

**The install script and Dockerfile will try to install the following pre-requisites for you**

 - Python 3.6
 - Ansible 2.9
 - [Ansible Role](https://galaxy.ansible.com/mkanoor/catalog_receptor_installer)

The Ansible role installs the receptor and the plugin, and configures it so its visible in the cloud.redhat.com. After the installation is successful we
1. Add a Source in the cloud.redhat.com
2. Add an End Point for this receptor node
3. Add Automation Services Catalog as a valid application for the Source.

This repo contains sample_playbooks for vm and container. You would setup the url and the token for the tower in the playbooks. Tokens are the recommended way for the plugin to authenticate with the Ansible Tower. To read more about Ansible tokens refer to https://docs.ansible.com/ansible-tower/latest/html/administration/oauth2_token_auth.html

## Usage: VM or Physical Machine

 - Clone this repository to your VM or Physical Machine
 - Edit the *sample_playbooks/vm/install_receptor.yml* playbook and update the Ansible Tower information
 - If your system needs to be registered with Red Hat Subscription Manager please set the following environment variables
 - **export RHN_USER=<<your_RHN_username>>**
 - **export RHN_PASSWORD=<<your_RHN_password>>**
 - **export RHSM_URL=<<Your QA/CI Subscription Manager URL>> (optional)**
 - Run the following command ( **install.sh sample_playbooks/vm/install_receptor.yml**)
 - After the install completes you should be able to have a system service running for the receptor

A QA Repository can be specified via an environment variable, this repo would contain the  RPM's for the receptor, catalog receptor plugin and their dependencies.

e.g.

export **QA_REPO**=......

**install.sh sample_playbooks/vm/install_receptor_qa.yml**

## Usage: Docker Container

- Docker has to be installed.
- Clone this repository to your environment
- Edit the sample_playbooks/container/install_receptor.yml playbook and update the Ansible Tower information
- The attached Dockerfile uses private images so you have to login using docker login
- As part of the docker build you have to pass in the user and password for registering your container with Red Hat Subscription Manager
- After the installation is configured the receptor would be running in the container.
- When running the container we mount the local directory into the container, with the -v option, the path needs to be fully qualified.
- When doing the docker build you can pass RHSM_URL to point to a QA/CI subscription manager


**docker login https://registry.redhat.io**

**docker build --build-arg USERNAME=<<your_rhn_user>> --build-arg  PASSWORD=<<your_rhn_password>> --tag receptor_installer .**

or

**docker build --build-arg RHSM_URL=<<rhsm_qa_url>> --build-arg USERNAME=<<your_rhn_user>> --build-arg  PASSWORD=<<your_rhn_password>> --build-arg  QA_REPO=<<your_qa_repo_url>> --tag receptor_installer .**

**docker run -it  -v <<your_current_dir>>/sample_playbooks/container:/playbooks receptor_installer**

If you want to test this as a Developer or a QE you can change the entry point and pass in your playbook

**docker run -it -v <<your_current_dir>>/sample_playbooks/container:/playbooks --entrypoint /bin/entrypoint.sh receptor_installer install_receptor_qa.yml**

