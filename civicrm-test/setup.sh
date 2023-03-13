#!/bin/bash

apt-get -y install ansible git || exit -1
git clone https://github.com/tpokorra/Hostsharing-Ansible-CiviCRM.git || exit -1
cd Hostsharing-Ansible-CiviCRM
cp ~/.ssh/civicrm.inventory.yml my.inventory.yml

# read civicrm version from latest github tag that is not a .0 release
civicrm_version=`curl https://github.com/civicrm/civicrm-core/tags --silent | grep "/civicrm/civicrm-core/releases/tag/" | grep -v '.0"' | head -n 1 | awk -F'"' '{print $6}' | awk -F'/' '{print $NF}'`

# actually, the .0 is also a stable release, and can be followed by the next higher .0 release
civicrm_version=`curl https://github.com/civicrm/civicrm-core/tags --silent | grep "/civicrm/civicrm-core/releases/tag/" | head -n 1 | awk -F'"' '{print $6}' | awk -F'/' '{print $NF}'`
echo "using civicrm_version " $civicrm_version
echo "      civicrm_version: $civicrm_version" >> my.inventory.yml
# use the composer version from the inventory template
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
ansible-playbook -i my.inventory.yml playbook-init.yml || exit -1
ansible-playbook -i my.inventory.yml playbook-install.yml || exit -1
ansible-playbook -i my.inventory.yml playbook-update.yml || exit -1
ansible-playbook -i my.inventory.yml playbook-uninstall.yml || exit -1
