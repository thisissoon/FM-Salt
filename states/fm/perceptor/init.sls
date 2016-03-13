#!stateconf yaml . jinja

#
# Run the SOON_ FM Frontend Container
#

{% set image = 'soon/fm-perceptor' %}
{% set tag = 'latest' %}
{% set port = 37000 %}
{% set server_name = salt['pillar.get']('services:perceptor:server_name', 'perceptor.thisissoon.fm') %}

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

# Configuration
.config:
  file.managed:
    - name: /etc/perceptor/perceptor.yml
    - source: salt://fm/perceptor/files/config.yml
    - makedirs: True
    - template: jinja
    - conext:
      redis: 172.17.0.1
      soundwave_secret: {{ salt['pillar.get']('secrets:soundwave', 'n/a') }}
      shockwave_secret: {{ salt['pillar.get']('secrets:shockwave', 'n/a') }}

# Run the container
.container:
  dockerng.running:
    - name: soon.fm.perceptor
    - image: {{ image }}:{{ tag }}
    - restart_policy: always
    - port_bindings:
      - {{ port }}:9000
    - binds:
      - /etc/perceptor:/etc/perceptor
    - environment:
      - PERCEPTOR_LOG_LEVEL: warn
    - watch:
      - dockerng: .image
      - file: .config

# Nginx Configuration
.nginx:
  file.managed:
    - name: /etc/nginx/conf.d/{{ server_name }}.conf
    - source: salt://fm/perceptor/files/nginx.conf
    - mode: 644
    - template: jinja
    - conext:
      port: {{ port }}
      server_name: {{ server_name }}
    - require:
      - dockerng: .container
    - watch_in:
      - service: nginx::nginx
