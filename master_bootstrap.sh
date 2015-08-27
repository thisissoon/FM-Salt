#!/usr/bin/env bash

apt-get install build-essential python-dev

wget -O install_salt.sh https://bootstrap.saltstack.com
sudo sh install_salt.sh -M -P -D

cat <<EOF >/etc/salt/grains
roles:
  - salt-master
EOF
