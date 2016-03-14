#!stateconf yaml . jinja

#
# Run the SOON_ FM Frontend Container
#

{% set image = 'quay.io/thisissoon/fm-frontend' %}
{% set tag = 'prod' %}
{% set port = 35000 %}
{% set server_name = salt['pillar.get']('services:frontend:server_name', 'thisissoon.fm') %}

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
    - name: soon.fm.frontend
    - image: {{ image }}:{{ tag }}
    - restart_policy: always
    - port_bindings:
      - {{ port }}:80
    - watch:
      - dockerng: .image

# Nginx Configuration
.nginx:
  file.managed:
    - name: /etc/nginx/conf.d/{{ server_name }}.conf
    - source: salt://fm/frontend/files/nginx.conf
    - mode: 644
    - template: jinja
    - conext:
      port: {{ port }}
      server_name: {{ server_name }}
    - require:
      - dockerng: .container
    - watch_in:
      - service: nginx::nginx
