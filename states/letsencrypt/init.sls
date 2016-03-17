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
{% set aws_account_id = salt['pillar.get']('aws:id', 'n/a') %}
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
# Constants
{% set conf_path = config_dir + '/' + domain + '.conf' %}
{% set cert_path = root + '/live/' + domain %}
{% set cert_name = salt['pillar.get']('letsencrypt:domains:' + domain + ':cert_name', None) %}
{% set elb_name = salt['pillar.get']('letsencrypt:domains:' + domain + ':elb_name', None) %}
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

# If the certificates do not exist we need to create them, override the cert name
{% if not salt['file.directory_exists'](cert_path) %}
{% set cert_name = domain + '.letsencrypt.' + "today"|strftime("%Y.%m.%d") %}
{% endif %}

# Create certificates with lets encrypt if they do not exist
.{{ domain }}_create_certificates:
  cmd.run:
    - name: letsencrypt certonly --agree-tos --config {{ conf_path }}
    - unless: test -d {{ cert_path }}
    - env:
      - PATH: {{ [salt['environ.get']('PATH', '/bin:/usr/bin'), venv + '/bin']|join(':') }}
    - require:
      - pip: .letsencrypt
      - file: .{{ domain }}_le_config

# Set the pillar cert name to be the one we just made, if we made one
.{{ domain }}_set_pillar:
  etcd.wait_set:
    - name: /salt/pillar/shared/letsencrypt/domains/{{ domain }}/cert_name
    - value: {{ cert_name }}
    - profile: master_etcd
    - watch:
      - cmd: .{{ domain }}_create_certificates

# Ensure the certificates exist in AWS IAM
.{{ domain }}_iam_certificate:
  boto_server_certificate.present:
    - name: {{ cert_name }}
    - public_key: {{ cert_path + '/cert.pem' }}
    - private_key: {{ cert_path + '/privkey.pem' }}
    - cert_chain: {{ cert_path + '/chain.pem' }}
    - region: {{ aws_region }}
    - keyid: {{ aws_keyid }}
    - key: {{ aws_key }}
    - require:
      - cmd: .{{ domain }}_create_certificates
      - stateconf: python::goal

# Ensure the ELB for this domain
.{{ domain }}_elb_listener:
  boto_elb_listener.managed:
    - elb: {{ elb_name }}
    - elb_port: 443
    - elb_proto: SSL
    - instance_port: 80
    - instance_proto: TCP
    - certificate_arn: arn:aws:iam::{{ aws_account_id }}:server-certificate/{{ cert_name }}
    - region: {{ aws_region }}
    - keyid: {{ aws_keyid }}
    - key: {{ aws_key }}
    - require:
      - boto_server_certificate: .{{ domain }}_iam_certificate
{% endfor %}
