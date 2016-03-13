#!stateconf yaml . jinja

#
# Run the SOON_ FM Websockets Container
#

{% set image = 'soon/fm-socket' %}
{% set tag = 'latest' %}
{% set port = 36000 %}
{% set server_name = salt['pillar.get']('services:websockets:server_name', 'sockets.thisissoon.fm') %}

# Dependencies
include:
  - docker
  - nginx

# Download latest image
.image:
  dockerng.image_present:
    - name: {{ image }}:{{ tag }}
    - force: True
    - require:
      - stateconf: docker::goal

# Run the container
.container:
  dockerng.running:
    - name: soon.fm.websockets
    - image: {{ image }}:{{ tag }}
    - restart_policy: always
    - port_bindings:
      - {{ port }}:8080
    - environment:
      - SOCKET_LOG_LEVEL: 'verbose'
      - REDIS_URI: redis://172.17.0.1:6379
      - REDIS_CHANNEL: fm:events
    - watch:
      - dockerng: .image

# Nginx Configuration
.nginx:
  file.managed:
    - name: /etc/nginx/conf.d/{{ server_name }}.conf
    - source: salt://fm/websockets/files/nginx.conf
    - mode: 644
    - template: jinja
    - conext:
      port: {{ port }}
      server_name: {{ server_name }}
    - require:
      - dockerng: .container
    - watch_in:
      - service: nginx::nginx
