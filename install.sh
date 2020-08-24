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

function attach_pool() {
  if [[ -z "${RHSM_POOL_ID}" ]]
  then
    return
  fi

  subscription-manager attach --pool $RHSM_POOL_ID

  if [[ $? -ne 0 ]]
  then
    echo "Could not attach pool with ID $RHSM_POOL_ID"
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
  echo "Enabling Ansible 2.9 repos"
  subscription-manager repos --enable ansible-2.9-for-rhel-8-x86_64-rpms
elif [[ "$MAJOR_VERSION" -eq 7 ]]
then
  echo "Enabling Ansible 2.9 repos"
  subscription-manager repos --enable rhel-7-server-ansible-2.9-rpms
  subscription-manager repos --enable rhel-7-server-extras-rpms
else
  echo "Unsupported version of RHEL $MAJOR_VERSION"
  exit 1
fi

echo "Enabling Receptor Catalog Repo"
attach_pool

if [[ "$MAJOR_VERSION" -eq 8 ]]
then
  subscription-manager repos --enable automation-services-catalog-1-beta-for-rhel-8-x86_64-rpms
  if [[ $? -ne 0 ]]
  then
    echo "Could not enable automation-services-catalog-1-beta-for-rhel-8-x86_64-rpms"
    echo "Try providing a pool id using an enviornment variable RHSM_POOL_ID"
    exit 1
  fi
elif [[ "$MAJOR_VERSION" -eq 7 ]]
then
  subscription-manager repos --enable rhel-7-server-automation-services-catalog-1-beta-rpms
  if [[ $? -ne 0 ]]
  then
    echo "Could not enable rhel-7-server-automation-services-catalog-1-beta-rpms"
    echo "Try providing a pool id using an enviornment variable RHSM_POOL_ID"
    exit 1
  fi
fi

if [[ "$MAJOR_VERSION" -eq 7 ]]
then
  yum install -y python3 python2-jmespath ansible
else
  yum install -y ansible
fi

# Install the Ansible Galaxy Role for the installer
ansible-galaxy install mkanoor.catalog_receptor_installer

echo "Running Playbook $1"
ansible-playbook $1
