#!stateconf yaml . jinja

#
# Install and run the Docker Service
#

include:
  - python
  - python-software-properties
  - apt-transport-https

# Install Docker Repo
.lxc-docker:
  pkgrepo.managed:
    - name: deb https://get.docker.com/ubuntu docker main
    - keyserver: hkp://keyserver.ubuntu.com:80
    - keyid: 36A1D7869245C8950F966E92D8576A8BA88D21E9
    - require:
      - stateconf: apt-transport-https::goal
      - stateconf: python-software-properties::goal

# Install & Run Docker & Install docker-py
.docker:
  pkg.installed:
    - name: lxc-docker-1.5.0
    - require:
      - pkgrepo: .lxc-docker
  service.running:
    - name: docker
    - sig: /usr/bin/docker
    - require:
      - pkg: .docker
  pip.installed:
    - name: docker-py
    - reload_modules: True
    - requie:
      - pkg: .docker
      - stateconf: python.install::goal
