#!stateconf yaml . jinja

#
# Install Lets Encrypt
#

{% set python_venv_root = salt['pillar.get']('python:virtualenv:root', '/.virtualenvs') %}
{% set venv = python_venv_root + '/' + salt['pillar.get']('letsencrypt:venv:name', 'letsencrypt') %}

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
    - name: /etc/letsencrypt/conf.d
    - makedirs: true

# WebRoot Path
.webroot:
  file.directory:
    - name: /var/www/letsencrypt
    - makedirs: true

# Nginx Include Snippet
.nginx:
  file.managed:
    - name: /etc/letsencrypt/nginx.include.conf
    - source: salt://letsencrypt/files/nginx.include.conf
    - makedirs: true
    - template: jinja
