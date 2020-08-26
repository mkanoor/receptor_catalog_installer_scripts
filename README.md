
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
4. Trigger an availability check on the source, which will cause an inventory refresh to run

This repo contains sample_playbooks for use in QA environment and production. You would setup the url and the token for the tower in the playbooks. Tokens are the recommended way for the plugin to authenticate with the Ansible Tower. To read more about Ansible tokens refer to https://docs.ansible.com/ansible-tower/latest/html/administration/oauth2_token_auth.html

## Usage: VM or Physical Machine
   The installer can only be run on systems that are registered with Red Hat

   To register a VM use the following command
   **subscription-manager register --username <<your_username>> --password <<your_password>>**

   To access the RPM repository you need a Pool ID. The pool id can be found by running
   the following command

   **subscription-manager list --available --all**

   And search the Pool ID for **Red Hat Ansible Automation, Standard**
   Snippet

   
  Subscription Name:Red Hat Ansible Automation, Standard (5000 Managed Nodes). 

 Provides:  Red Hat Ansible Engine. 

SKU: MCT3692. 

Contract:  xxxxxx. 

**Pool ID: your_pool_id**. 

Provides Management: No. 

Available: 50000. 

Suggested: 1*. 


   This Pool ID can be set in the environment variable for the installer to use

   **export RHSM_POOL_ID=your_pool_id**

### GIT installed in VM
 - Clone this repository to your VM or Physical Machine
 - Edit the *sample_playbooks/install_receptor.yml* playbook and update the Ansible Tower information
 - Run the following command ( **install.sh sample_playbooks/install_receptor.yml**)
 - After the install completes you should be able to have a system service running for the receptor


**install.sh sample_playbooks/install_receptor_qa.yml**

### GIT not installed in VM

If you dont have git installed in the VM you can download two files using cURL


*curl -O https://raw.githubusercontent.com/mkanoor/receptor_catalog_installer_scripts/master/install.sh*


*curl -O https://raw.githubusercontent.com/mkanoor/receptor_catalog_installer_scripts/master/sample_playbooks/install_receptor_qa.yml*

Then edit the install_receptor_qa.yml save the changes and run

**install.sh install_receptor_qa.yml**


## Usage: Docker Container

- Docker has to be installed.
- Clone this repository to your environment
- Edit the sample_playbooks/install_receptor.yml playbook and update the Ansible Tower information
- The attached Dockerfile uses private images so you have to login using docker login
- As part of the docker build you have to pass in the user and password for registering your container with Red Hat Subscription Manager
- After the installation is configured the receptor would be running in the container.
- When running the container we mount the local directory into the container, with the -v option, the path needs to be fully qualified.
- When doing the docker build you can pass RHSM_URL to point to a QA/CI subscription manager


**docker login https://registry.redhat.io**

**docker build --build-arg USERNAME=<<your_rhn_user>> --build-arg  PASSWORD=<<your_rhn_password>> --build-arg RHSM_POOL_ID=<<your_pool_id>> --tag receptor_installer .**


**docker run -it  -v <<your_current_dir>>/sample_playbooks:/playbooks receptor_installer**

If you want to test this as a Developer or a QE you can change the entry point and pass in your playbook

**docker run -it -v <<your_current_dir>>/sample_playbooks:/playbooks --entrypoint /bin/entrypoint.sh receptor_installer install_receptor_qa.yml**

If you wan to run this with Proxy server use the following command
**docker run --env HTTPS_PROXY=<<your_proxy>> -it -v <<your_current_dir>>/sample_playbooks:/playbooks --entrypoint /bin/entrypoint.sh receptor_installer install_receptor_qa.yml**

