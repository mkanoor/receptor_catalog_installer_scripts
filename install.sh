#! /bin/sh

# If the system is not registered. Please set the following
# environment variables, and the script will try to register
# the systemi for you
# export RHN_USER=your_username
# export RHN_PASSWORD=your_password
# Optionally you can set the RHSM_URL if you have a QA or Dev System
# export RHSM_URL=your_rhsm_url

# Pre Requisites
# Python 3.6
# Ansible 2.9

# Temporary pre requisites
# wget
# yum-utils

function install() {
   yum list installed | grep $1
   if [[ $? -eq 0 ]]
   then
     echo "Package $1 is already installed"
   else
     echo "Attempting to install $1"
     yum install -y $1
     if [[ $? -ne 0 ]]
     then
       echo "Could not install package $1 hence exiting"
       exit 1
     fi
   fi
}

function prep_qa_environment() {
  if [[ -z "${QA_REPO}" ]]
  then
    echo "QA Repo not added"
  else
    # Package needed to add temporary repos till we get an official repository
    install yum-utils

    # Package needed to fetch the IT ROOT CA certificate
    install wget

    yum-config-manager --add-repo=$QA_REPO
    # When running in CI environment we need to check the cert
    # is signed by Redhat IT ROOT CA
    # Needed only if we are connecting to ci.cloud.redhat.com
    wget -P /etc/pki/ca-trust/source/anchors/ https://password.corp.redhat.com/RH-IT-Root-CA.crt
    update-ca-trust
  fi
}

function register_system() {
  if [[ -z "${RHN_USER}" ]]
  then 
    echo "Please set the environment variable RHN_USER so we can register this system"
    exit 1
  fi

  if [[ -z "${RHN_PASSWORD}" ]]
  then 
    echo "Please set the environment variable RHN_PASSWORD so we can register this system"
    exit 1
  fi

  rhsm_url="${RHSM_URL:-https://subscription.rhsm.redhat.com/subscription}"
  subscription-manager register --serverurl $rhsm_url --username $RHN_USER --password $RHN_PASSWORD --auto-attach

  if [[ $? -ne 0 ]]
  then
    echo "Registration failed, exiting"
    exit 1
  fi
}

REDHAT_RELEASE_FILE=/etc/redhat-release

if [[ ! -f "$REDHAT_RELEASE_FILE" ]]
then
  echo "This installer can only be run on RHEL systems"
  exit 1
fi

if [[ $# -eq 0 ]]
then
    echo "usage: install.sh playbook"
    exit 1
fi

if [[ ! -f "$1" ]]
then
  echo "Playbook file $1 not found"
  exit 1
fi

# Register the system if we dont have certs
FILE=/etc/pki/consumer/cert.pem
if [[ ! -f "$FILE" ]]
then
  register_system
fi

MAJOR_VERSION=`cat /etc/os-release | grep -w VERSION_ID | cut -d= -f2 | tr -d '"' | cut -d. -f1`
if [[ "$MAJOR_VERSION" -eq 8 ]]
then
  subscription-manager repos --enable ansible-2.9-for-rhel-8-x86_64-rpms
elif [[ "$MAJOR_VERSION" -eq 7 ]]
then
  subscription-manager repos --enable rhel-7-server-ansible-2.9-rpms
  subscription-manager repos --enable rhel-7-server-extras-rpms
else
  echo "Unsupported version of RHEL $MAJOR_VERSION"
  exit 1
fi

if [[ "$MAJOR_VERSION" -eq 7 ]]
then
  install python3
fi

install ansible

# Install the Ansible Galaxy Role for the installer
ansible-galaxy install mkanoor.catalog_receptor_installer

# Setup RPM repo for the python receptor & catalog plugin
prep_qa_environment

if [[ "$MAJOR_VERSION" -eq 7 ]]
then
  install python2-jmespath
fi

echo "Running Playbook $1"
ansible-playbook $1
