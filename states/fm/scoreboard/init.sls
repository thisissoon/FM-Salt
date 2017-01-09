#!stateconf yaml . jinja

#
# Run the SOON_ FM Scoreboard
#

{% set image = 'quay.io/thisissoon/fm-scoreboard' %}
{% set tag = 'latest' %}
{% set port = 38000 %}

include:
  - docker
  - influxdb
  - nginx
  - redis

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
    - name: /etc/scoreboard/config.toml
    - source: salt://fm/scoreboard/files/config.toml
    - makedirs: True
    - template: jinja

# Run the container
.container:
  dockerng.running:
    - name: soon.fm.scoreboard
    - image: {{ image }}:{{ tag }}
    - restart_policy: always
    - port_bindings:
      - {{ port }}:5000
    - binds:
      - /etc/scoreboard:/etc/scoreboard
    - watch:
      - dockerng: .image
      - file: .config

# Nginx Configuration
.nginx:
  file.managed:
    - name: /etc/nginx/conf.d/scoreboard.fm.internal.conf
    - source: salt://fm/scoreboard/files/nginx.conf
    - mode: 644
    - template: jinja
    - conext:
      port: {{ port }}
      server_name: scoreboard.fm.internal
    - require:
      - dockerng: .container
    - watch_in:
      - service: nginx::nginx
