#!stateconf yaml . jinja

#
# Lets Encrypt Macros to help enabling LE SSL Support
# with ACME challenge
#

include:
  - letsencrypt
  - python

{% set le_root = salt['pillar.get']('letsencrypt:root', '/etc/letsencrypt') %}
{% set config_root = salt['pillar.get']('letsencrypt:config:root', le_root + '/conf.d') %}
{% set python_venv_root = salt['pillar.get']('python:virtualenv:root', '/.virtualenvs') %}
{% set venv = python_venv_root + '/' + salt['pillar.get']('letsencrypt:venv:name', 'letsencrypt') %}

# Generates a state for standard LE config for a domain. Does not need LE to be installed
# first. Use the name keyword argument to name the state, sefaults to stateconf .le_config
{% macro config(domain, email, key_size=None, name=None, server=None) %}
{{ name|default('.le_config') }}:
  file.managed:
    - name: {{ config_root }}/{{ domain }}.conf
    - source: salt://letsencrypt/files/domain.config.conf
    - template: jinja
    - makedirs: True
    - context:
      domain: {{ domain }}
      email: {{ email }}
      key_size: {{ key_size }}
      server: {{ server }}
{% endmacro %}

# A macro for generating LE SSL certs if we have not yet generated them, this will
# typically occure on the first run. You can oass optional requite, watch and watch_in
# arguments to ensure this command only runs when it should and notifies other
# states of changes
#
# e.g
# {#
# {{ generate_certs('foo.com', require=[('file', '.le_config')], watch_in=[('file', '.nginx')] }}
# #}
#
# Use the name keyword argument to name the state, defaults too stateconf '.le_generate_certs'
{% macro generate_certs(domain, require=[], watch=[], watch_in=[], name=None) -%}
{% set current_path = salt['environ.get']('PATH', '/bin:/usr/bin') %}
{% set cert_path = le_root + '/live/' + server_name %}
{{ name|default('.le_generate_certs') }}:
  cmd.run:
    - name: letsencrypt --agree-tos --config {{ config_root }}/{{ domain }}.conf certonly
    - env:
      - PATH: {{ [current_path, venv + '/bin']|join(':') }}
    - unless: test -d {{ cert_path }}
    {% if require|length > 0 %}
    - require:
      {% for func, subject in require %}
      - {{ func }}: {{ subject }}
      {% endfor %}
    {% endif %}
    {% if watch|length > 0 %}
    - watch:
      {% for func, subject in watch %}
      - {{ func }}: {{ subject }}
      {% endfor %}
    {% endif %}
    {% if watch_in|length > 0 %}
    - watch_in:
      {% for func, subject in watch_in %}
      - {{ func }}: {{ subject }}
      {% endfor %}
    {% endif %}
{% endmacro %}

# Macro for uploading a server certificate to IAM
{% macro elb_cert(server_name, keyid, key, region='eu-west-1', name='.le_elb_certificate', watch=[]) %}
{% set cert_path = le_root + '/live/' + server_name %}
{{ name }}:
  boto_iam.server_cert_present:
    - name: {{ server_name }}.le.{{ "today"|strftime("%Y.%m.%d") }}
    - public_key: {{ cert_path }}/cert.pem
    - private_key: {{ cert_path }}/privkey.pem
    - cert_chain: {{ cert_path }}/chain.pem
    - region: {{ region }}
    - keyid: {{ keyid }}
    - key: {{ key }}
    {% if watch|length > 0 %}
    - watch:
      {% for func, subject in watch %}
      - {{ func }}: {{ subject }}
      {% endfor %}
    {% endif %}
    - require:
      - stateconf: python::goal
{% endmacro %}
