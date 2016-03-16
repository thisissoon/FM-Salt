#!stateconf yaml . jinja

#
# Install Lets Encrypt
#

{% set python_venv_root = salt['pillar.get']('python:virtualenv:root', '/.virtualenvs') %}
{% set venv = python_venv_root + '/' + salt['pillar.get']('letsencrypt:venv:name', 'letsencrypt') %}
{% set le_root = salt['pillar.get']('letsencrypt:root', '/etc/letsencrypt') %}
{% set config_root = salt['pillar.get']('letsencrypt:config:root', le_root + '/conf.d') %}

include:
  - python

# Dependency Packages
.dependencies:
  pkg.installed:
    - pkgs:
      - gcc
      - dialog
      - libaugeas0
      - augeas-lenses
      - libssl-dev
      - libffi-dev
      - ca-certificates
    - require:
      - stateconf: python::goal

# Install Lets Encrypt from pypi into virtualenv
.letsencrypt:
  virtualenv.managed:
    - name: {{ venv }}
    - require:
      - stateconf: python::goal
  pip.installed:
    - name: letsencrypt == 0.4.2
    - bin_env: {{ venv }}
    - require:
      - virtualenv: .letsencrypt
      - pkg: .dependencies

# Config Dir
.configdir:
  file.directory:
    - name: {{ config_root }}
    - makedirs: true

# WebRoot Path
.webroot:
  file.directory:
    - name: /var/www/letsencrypt
    - makedirs: true
