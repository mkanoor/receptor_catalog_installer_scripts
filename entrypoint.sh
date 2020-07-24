#!/bin/sh

RECEPTOR=/etc/receptor/rh_ansible_tower/receptor.sh
UUID_FILE=/etc/receptor/rh_ansible_tower/uuid
CONFIG_FILE=/etc/receptor/rh_ansible_tower/receptor.conf

FILE="/playbooks/$1"

if [[ -f "$FILE" ]]
then
  ansible-playbook $FILE
  if [[ $? -eq 0 ]]
  then 
    echo "Starting the receptor $RECEPTOR"
    cat $CONFIG_FILE
    echo -n "Receptor Node id is " && cat $UUID_FILE
    $RECEPTOR
  else
    echo "Install failed for receptor"
    exit 2
  fi
else
  echo "$FILE doesn't exist, please provide a playbook with install parameters"
  exit 1
fi
