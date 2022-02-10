#!/bin/bash

apt-get -y install ansible git || exit -1
git clone https://github.com/tpokorra/Hostsharing-Ansible-Mastodon.git || exit -1
cd Hostsharing-Ansible-Mastodon
cp ~/.ssh/mastodon.inventory.yml my.inventory.yml

eval `ssh-agent`
ssh-add ~/.ssh/id_rsa_cronjob

ansible-playbook -i my.inventory.yml playbook-uninstall.yml || exit -1
ansible-playbook -i my.inventory.yml playbook-mastodon.yml || exit -1
ansible-playbook -i my.inventory.yml playbook-uninstall.yml || exit -1
