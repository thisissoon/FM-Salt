#!stateconf yaml . jinja

#
# Install and run the Docker Service
#

{% set DOCKER_VERSION = "1.10.3" %}

include:
  - python
  - python-software-properties
  - apt-transport-https

# Install & Run Docker & Install docker-py
.docker:
  pkg.installed:
    - sources:
      - docker-engine: http://apt.dockerproject.org/repo/pool/main/d/docker-engine/docker-engine_{{ DOCKER_VERSION }}-0~trusty_amd64.deb
  service.running:
    - name: docker
    - sig: /usr/bin/docker
    - require:
      - pkg: .docker
  pip.installed:
    - name: docker-py
    - reload_modules: True
    - require:
      - pkg: .docker
      - stateconf: python::goal
