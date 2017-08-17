#!/bin/bash
ANSIBLE_CONFIG=$HOME/code/grab/ansible/ansible.cfg ansible-playbook -u ec2-user -e target=all  $HOME/code/grab/ansible/main.yml -i "$1,"