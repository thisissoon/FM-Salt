#!stateconf yaml . jinja

#
# Install Lets Encrypt
#

{% set python_venv_root = salt['pillar.get']('python:virtualenv:root', '/.virtualenvs') %}
{% set venv = python_venv_root + '/letsencrypt' %}
{% set root = '/etc/letsencrypt' %}
{% set config_dir = root + '/conf.d' %}
{% set server_name = salt['pillar.get']('letsencrypt:server_name', 'letsencrypt.internal') %}
{% set webroot_path = '/var/www/letsencrypt' %}

include:
  - python
  - nginx

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
      - pkg: .dependencies
  pip.installed:
    - name: letsencrypt == 0.4.2
    - bin_env: {{ venv }}
    - require:
      - virtualenv: .letsencrypt

# Config Dir
.configdir:
  file.directory:
    - name: {{ config_dir }}
    - makedirs: true

# WebRoot Path
.webroot:
  file.directory:
    - name: {{ webroot_path }}
    - makedirs: true

# Nginx Configuration
# Adds Nginx Server configurations for each domain we want SSL certificates
# managed for
.nginx:
  file.managed:
    - name: /etc/nginx/conf.d/letsencrypt.conf
    - source: salt://letsencrypt/files/nginx.conf
    - template: jinja
    - context:
      webroot_path: {{ webroot_path }}
    - require:
      - pip: .letsencrypt
    - watch_in:
      - service: nginx::nginx
