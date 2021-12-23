#!/bin/bash

apt-get -y install ansible git || exit -1
git clone https://github.com/tpokorra/Hostsharing-Ansible-CiviCRM.git || exit -1
cd Hostsharing-Ansible-CiviCRM
cp ~/.ssh/civicrm.inventory my.inventory

eval `ssh-agent`
ssh-add ~/.ssh/id_rsa_cronjob

ansible-playbook -i my.inventory playbook-uninstall.yml || exit -1
ansible-playbook -i my.inventory playbook-civicrm.yml || exit -1
ansible-playbook -i my.inventory playbook-update.yml || exit -1
ansible-playbook -i my.inventory playbook-uninstall.yml || exit -1
