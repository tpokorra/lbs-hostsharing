#!/bin/bash

apt-get -y install ansible git || exit -1
git clone https://github.com/tpokorra/Hostsharing-Ansible-CiviCRM.git || exit -1
cd Hostsharing-Ansible-CiviCRM
cp ~/.ssh/civicrm.inventory.yml my.inventory.yml

# use the civicrm version from the inventory template
cat inventory-template.yml | grep "civicrm_version" >> my.inventory.yml
cat inventory-template.yml | grep "composer_version" >> my.inventory.yml

eval `ssh-agent`
ssh-add ~/.ssh/id_rsa_cronjob

# avoid error: Shared connection to example.org closed. Terminated. MODULE FAILURE See stdout/stderr for the exact error
export ANSIBLE_SSH_ARGS="-o ServerAliveInterval=50"
# to avoid error: Failed to connect to the host via ssh: ssh: connect to host example.org port 22: Cannot assign requested address
export ANSIBLE_SSH_RETRIES=10
# see https://wiki.hostsharing.net/index.php/SSH_Rate_Limit
cat >> $HOME/.ssh/config << FINISH
Host *.hostsharing.net
ControlPath ~/.ssh/cm-%r@%h:%p
ControlMaster auto
ControlPersist 10m
FINISH

ansible-playbook -i my.inventory.yml playbook-uninstall.yml || exit -1
ansible-playbook -i my.inventory.yml playbook-install.yml || exit -1
ansible-playbook -i my.inventory.yml playbook-update.yml || exit -1
ansible-playbook -i my.inventory.yml playbook-uninstall.yml || exit -1
