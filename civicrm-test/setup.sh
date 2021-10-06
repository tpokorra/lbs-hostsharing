#!/bin/bash

apt-get -y install ansible git || exit -1
git clone https://github.com/tpokorra/Hostsharing-Ansible-CiviCRM.git || exit -1
cd Hostsharing-Ansible-CiviCRM
cp ~/.ssh/civicrm.inventory my.inventory

# see https://stackoverflow.com/a/29213873/1632368
# ansible-vault create secret
#   with content: ansible_become_pass: mypassword
# password stored in vault.txt
cp ~/.ssh/vault.txt vault.txt
cp ~/.ssh/hs_secret secret

eval `ssh-agent`
ssh-add ~/.ssh/id_rsa_cronjob

ansible-playbook -i my.inventory playbook-civicrm.yml -k --vault-password-file=vault.txt || exit -1
