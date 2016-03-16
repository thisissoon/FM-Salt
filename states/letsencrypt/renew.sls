#!stateconf yaml . jinja

#
#  Renew SSL Certificates via Lets Encrypt
#

# Renew certificates
{% for domain, meta in salt['pillar.get']('letsencrypt:domains', {}).iteritems() %}
{% set conf_path = config_dir + '/' + domain + '.conf' %}
{% set cert_path = root + '/live/' + domain %}
# Renew the certificates
.{{ domain }}_renew_certificates:
  cmd.run:
    - name: letsencrypt certonly --renew --agree-tos --config {{ conf_path }}
    - unless: test -d {{ cert_path }}
    - env:
      - PATH: {{ [salt['environ.get']('PATH', '/bin:/usr/bin'), venv + '/bin']|join(':') }}
{% endfor %}
