#!/bin/bash

apt-get -y install ansible git || exit -1
git clone https://github.com/tpokorra/Hostsharing-Ansible-Mastodon.git || exit -1
cd Hostsharing-Ansible-Mastodon
cp ~/.ssh/mastodon.inventory my.inventory

# see https://stackoverflow.com/a/29213873/1632368
# ansible-vault create secret
#   with content: ansible_become_pass: mypassword
# password stored in vault.txt
cp ~/.ssh/vault.txt vault.txt
cp ~/.ssh/hs_secret secret

eval `ssh-agent`
ssh-add ~/.ssh/id_rsa_cronjob

ansible-playbook -i my.inventory playbook-uninstall.yml --vault-password-file=vault.txt || exit -1
ansible-playbook -i my.inventory playbook-mastodon.yml --vault-password-file=vault.txt || exit -1
ansible-playbook -i my.inventory playbook-uninstall.yml --vault-password-file=vault.txt || exit -1