#!stateconf yaml . jinja

#
# Run the SOON_ FM 2.0 to 1.0 legacy converter container
#

{% set image = 'quay.io/thisissoon/fm-legacy' %}
{% set tag = 'latest' %}

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

# Log File
.logfile:
  file.managed:
    - name: /var/log/sfm.legacy.log

# Create Config
.config:
  file.managed:
    - name: /etc/crest/legacy/config.toml
    - source: salt://crest/legacy/files/config.toml
    - makedirs: true
    - mode: 644
    - user: crest
    - group: crest
    - template: jinja
    - require:
      - stateconf: crest.user::goal

# Run the container
.container:
  dockerng.running:
    - name: soon.fm.legacy
    - image: {{ image }}:{{ tag }}
    - restart_policy: always
    - binds:
      - /etc/sfm/legacy:/etc/sfm/legacy
      - /var/log/legacy.log:/var/log/legacy.log
    - require:
      - file: .logfile
    - watch:
      - dockerng: .image
      - file: .config

