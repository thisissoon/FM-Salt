#!stateconf yaml . jinja

#
# Manage SSL Certificates for SOON_ FM Public domains
# These are managed automatically using Lets Encrypt. Once the certificates are
# generated they are uploaded to AWS IAM and then assigned to the ELB for each
# domain.
#
# This requires the frontend servers are up and running.
#

{% set canonical = 'thisissoon.fm' %}
{#
{% set domains = [canonical, 'api.' + canonical, 'sockets.' + canonical] %}
#}
{% set domains = [canonical, ] %}
{% set conf_path = '/etc/letsencrypt/conf.d/' + canonical + '.conf' %}
{% set current_path = salt['environ.get']('PATH', '/bin:/usr/bin') %}
{% set cert_root = '/etc/letsencrypt/live' %}
{% set python_venv_root = salt['pillar.get']('python:virtualenv:root', '/.virtualenvs') %}
{% set venv = python_venv_root + '/' + salt['pillar.get']('letsencrypt:venv:name', 'letsencrypt') %}

include:
  - fm.frontend
  - letsencrypt
  - python

# Lets Encrypt Config for the thisissoon.fm Domains
.config:
  file.managed:
    - name: {{ conf_path }}
    - source: salt://letsencrypt/files/domain.config.conf
    - template: jinja
    - makedirs: True
    - context:
      domains: {{ domains }}
      email: dorks+fm@thisissoon.com
      key_size: 4096
      server: https://acme-staging.api.letsencrypt.org/directory

{% set test_cmd = '' %}
{% for domain in domains %}
  {% set test_cmd = test_cmd + '[ -d ' + cert_root + '/' + domain  + ' ]' %}
  {% if not loop.last %}
    {% set test_cmd = test_cmd + " && " %}
  {% endif %}
{% endfor %}

.generate_certs:
  cmd.run:
    - name: letsencrypt --agree-tos --config {{ conf_path }} certonly
    - env:
      - PATH: {{ [current_path, venv + '/bin']|join(':') }}
    - unless: {{ test_cmd }}  # Only generate certs if we don't have any already
    - require:
      - file: .config
      - stateconf: fm.frontend::goal
