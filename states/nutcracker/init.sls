#!stateconf yaml . jinja

#
# Installs Nutctacker - a Redis Proxy Server by Twitter
#
# https://github.com/twitter/twemproxy
#

{% set listen_ip = '0.0.0.0' %}
{% set listen_port = '22121' %}
{% set servers = [{'addr': 'redis.fm.internal', 'port': 6379, 'weighting': 1}] %}

# Include Dependency States
include:
  - python-software-properties

.nutcracker:
  pkgrepo.managed:
    - ppa: twemproxy/stable
    - require:
      - stateconf: python-software-properties::goal
  pkg.installed:
    - name: twemproxy
    - watch_in:
      - service: .nutcracker
  file.managed:
    - name: /etc/nutcracker.conf
    - source: salt://nutcracker/files/nutcracker.yml
    - template: jinja
    - conext:
      servers: {{ servers }}
      listen_ip: {{ listen_ip }}
      listen_port: {{ listen_port }}
    - watch_in:
      - service: .nutcracker
  service.running:
    - name: twemproxy
    - enable: True
    - reload: True
    - require:
      - pkg: .nutcracker
      - file: .nutcracker
      - file: .default

.default:
  file.managed:
    - name: /etc/default/twemproxy.override
    - source: salt://nutcracker/files/twemproxy.override
    - require:
      - pkg: .nutcracker
    - watch_in:
      - service: .nutcracker
