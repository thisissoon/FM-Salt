#!/usr/bin/env bash

wget -O install_salt.sh https://bootstrap.saltstack.com
sudo sh install_salt.sh -P -D

cat <<EOF >/etc/salt/minion
master: 192.168.37.10
EOF


cat <<EOF >/etc/salt/grains
roles:
  - fm-stats
EOF

# Downgrade docker client
sudo pip install docker-py==1.1.0

service salt-minion restart
