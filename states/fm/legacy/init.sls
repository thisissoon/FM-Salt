#!stateconf yaml . jinja

#
# Run the SOON_ FM legacy
#

{% set image = 'quay.io/thisissoon/fm-legacy' %}
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
    - name: /etc/sfm/legacy/config.toml
    - source: salt://fm/legacy/files/config.toml
    - makedirs: True
    - template: jinja

# Log File
.logfile:
  file.touch:
    - name: /var/log/legacy.log
    - makedirs: True

# Run the container
.container:
  dockerng.running:
    - name: soon.fm.legacy
    - image: {{ image }}:{{ tag }}
    - restart_policy: always
    - binds:
      - /etc/sfm/legacy/config.toml:/etc/sfm/legacy/config.toml
      - /var/log/legacy.log:/var/log/legacy.log
    - require:
      - file: .logfile
    - watch:
      - dockerng: .image
      - file: .config
