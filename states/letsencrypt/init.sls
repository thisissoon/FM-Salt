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
{% set acme_server = salt['pillar.get']('letsencrypt:acme_server', 'https://acme-v01.api.letsencrypt.org/directory') %}
{% set aws_key = salt['pillar.get']('aws:iam:thisissoon.fm:key', 'n/a') %}
{% set aws_keyid = salt['pillar.get']('aws:iam:thisissoon.fm:keyid', 'n/a') %}
{% set aws_region = salt['pillar.get']('aws:iam:thisissoon.fm:region', 'eu-west-1') %}

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

# For each domain we want LE to manage certs for we need to:
# - Check if we have any certs (if not create them)
# - Upload the cert to IAM
# - Update the ELB to use that cert
# - Setup Renew cron, see renew.sls
{% for domain, meta in salt['pillar.get']('letsencrypt:domains', {}).iteritems() %}
{% set conf_path = config_dir + '/' + domain + '.conf' %}
{% set cert_path = root + '/live/' + domain %}
# Ensure we have a config for the domain
.{{ domain }}_le_config:
  file.managed:
    - name: {{ conf_path }}
    - source: salt://letsencrypt/files/domain.config.conf
    - template: jinja
    - makedirs: True
    - context:
      domain: {{ domain }}
      email: dorks+fm@thisissoon.com
      key_size: 4096
      server: {{ acme_server }}
    - require:
      - file: .configdir

# Create certificates with lets encrypt
.{{ domain }}_create_certificates:
  cmd.run:
    - name: letsencrypt certonly --agree-tos --config {{ conf_path }}
    - unless: test -d {{ cert_path }}
    - env:
      - PATH: {{ [salt['environ.get']('PATH', '/bin:/usr/bin'), venv + '/bin']|join(':') }}
    - require:
      - pip: .letsencrypt
      - file: .{{ domain }}_le_config

# Upload the certificates to AWS IAM
{{ domain }}_upload_to_iam:
  boto_server_certificate.present:
    - name: {{ domain }}.letsencrypt
    - public_key: {{ cert_path + '/cert.pem' }}
    - private_key: {{ cert_path + '/privkey.pem' }}
    - cert_chain: {{ cert_path + '/chain.pem' }}
    - region: {{ aws_region }}
    - keyid: {{ aws_keyid }}
    - key: {{ aws_key }}
    - require:
      - cmd: .{{ domain }}_create_certificates
      - stateconf: python::goal
{% endfor %}
