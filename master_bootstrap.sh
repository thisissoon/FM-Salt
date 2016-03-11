#!/usr/bin/env bash

version=2015.8.7+ds-1

mkdir -p /etc/salt

cat <<EOF >/etc/salt/grains
roles:
  - salt-master
EOF

mkdir -p /etc/salt/minion.d

apt-get update && apt-get install -y wget
wget -O - https://repo.saltstack.com/apt/ubuntu/ubuntu14/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add -
echo deb http://repo.saltstack.com/apt/ubuntu/ubuntu14/latest trusty main >> /etc/apt/sources.list.d/salt.list
apt-get update && apt-get install -y \
    salt-master=$version \
    salt-minion=$version \
    salt-api=$version
