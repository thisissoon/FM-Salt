#!stateconf yaml . jinja

#
# ETCD installation and service
#

{% set ETCD_VERSION = "2.2.5" %}

include:
  - python

# Install OS Package Dependencies
.dependencies:
  pkg.installed:
    - pkgs:
      - build-essential
      - libffi-dev
      - libssl-dev

# Download the release we want
.download:
  cmd.run:
    - name: curl -L https://github.com/coreos/etcd/releases/download/v{{ ETCD_VERSION }}/etcd-v{{ ETCD_VERSION }}-linux-amd64.tar.gz -o /etcd-v{{ ETCD_VERSION }}-linux-amd64.tar.gz
    - creates: /etcd-v{{ ETCD_VERSION }}-linux-amd64.tar.gz

# Unpack the tarball
.extracted:
  cmd.wait:
    - name: tar zxvf /etcd-v{{ ETCD_VERSION }}-linux-amd64.tar.gz
    - creates: /etcd-v{{ ETCD_VERSION }}-linux-amd64
    - cwd: /
    - watch:
      - cmd: .download

# Move etcd binary
.etcd:
  cmd.wait:
    - name: mv /etcd-v{{ ETCD_VERSION }}-linux-amd64/etcd /usr/local/bin
    - watch:
      - cmd: .extracted

# Move etcdctl binary
.etcdctl:
  cmd.wait:
    - name: mv /etcd-v{{ ETCD_VERSION }}-linux-amd64/etcdctl /usr/local/bin
    - watch:
      - cmd: .extracted

# Install python-etcd so Salt can talk to ETCD in states and execution modules
.python-etcd:
  pip.installed:
    - name: python-etcd
    - reload_modules: True
    - require:
      - pkg: .dependencies
      - stateconf: python::goal

# Manage ETCD Service
.service:
  file.managed:
    - name: /etc/init/etcd.conf
    - source: salt://etcd/files/init.conf
    - mode: 0644
    - require:
      - cmd: .etcd
  service.running:
    - name: etcd
    - enable: true
    - watch:
      - file: .service
    - require:
      - file: .service
