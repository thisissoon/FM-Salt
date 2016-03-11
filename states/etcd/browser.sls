#!stateconf yaml . jinja

#
# ETCD Browser
#

{% set image = 'johnmccabe/etcd-browser' %}
{% set tag = 'latest' %}
{% set name = 'etcd.browser' %}
{% set server_name = salt['pillar.get']('etcd:browser:server_name', 'fm.etcd.local') %}
{% set bind = '127.0.0.1:41000' %}

# Include Dependency States
include:
  - etcd
  - docker
  - nginx

.image:
  dockerng.image_present:
    - name: {{ image }}:{{ tag }}
    - force: true
    - require:
      - stateconf: docker::goal

.container:
  dockerng.running:
    - name: {{ name }}
    - image: {{ image }}:{{ tag }}
    - restart_policy: always
    - port_bindings:
      - {{ bind }}:8000
    - environment:
      - ETCD_HOST: '172.17.0.1'  # Host
      - ETCD_PORT: '4001'
      - SERVER_PORT: '8000'
    - watch:
      - dockerng: .image

.nginx:
  file.managed:
    - name: /etc/nginx/conf.d/etcd.conf
    - source: salt://etcd/files/nginx.conf
    - mode: 644
    - template: jinja
    - context:
      server_name: {{ server_name }}
      proxy_pass:  {{ bind }}
    - user: nginx
    - group: nginx
    - require:
      - dockerng: .container
    - watch_in:
      - service: nginx::nginx
