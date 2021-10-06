#!/bin/bash

apt-get -y install ansible git || exit -1
git clone https://github.com/tpokorra/Hostsharing-Ansible-CiviCRM.git || exit -1
cd Hostsharing-Ansible-CiviCRM
cp ~/.ssh/civicrm.inventory my.inventory
ansible-playbook -i my.inventory playbook-civicrm.yml -k  || exit -1





