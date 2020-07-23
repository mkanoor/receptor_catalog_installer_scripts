#!/bin/sh
if [ -z "$QA_REPO" ]; then
  echo "Prod env"
else
  # When running in CI environment we need to check the cert
  # is signed by Redhat IT ROOT CA
  # Needed only if we are connecting to ci.cloud.redhat.com
  wget -P /etc/pki/ca-trust/source/anchors/ https://password.corp.redhat.com/RH-IT-Root-CA.crt
  update-ca-trust
  # Setup RPM repo for the python receptor & catalog plugin
  dnf config-manager --add-repo=$QA_REPO
fi
