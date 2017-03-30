#!stateconf yaml . jinja

#
# Run the SOON_ FM Eventrelay
#

{% set image = 'quay.io/thisissoon/fm-eventrelay' %}
{% set tag = 'latest' %}

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
    - name: /etc/sfm/eventrelay/config.toml
    - source: salt://fm/eventrelay/files/config.toml
    - makedirs: True
    - template: jinja

# Log File
.logfile:
  file.touch:
    - name: /var/log/eventrelay.log
    - makedirs: True

# Run the container
.container:
  dockerng.running:
    - name: soon.fm.eventrelay
    - image: {{ image }}:{{ tag }}
    - restart_policy: always
    - binds:
      - /etc/sfm/eventrelay/config.toml:/etc/sfm/eventrelay/config.toml
      - /var/log/eventrelay.log:/var/log/eventrelay.log
    - port_bindings:
      - 8000:8000
    - require:
      - file: .logfile
    - watch:
      - dockerng: .image
      - file: .config
