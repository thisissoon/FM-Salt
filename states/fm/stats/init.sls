#!stateconf yaml . jinja

#
# Run the SOON_ FM Stats Container
#

{% set image = 'quay.io/thisissoon/fm-stats' %}
{% set tag = 'latest' %}

# Dependencies
include:
  - docker

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
    - name: soon.fm.stats
    - image: {{ image }}:{{ tag }}
    - restart_policy: always
    - environment:
      - AWS_S3_ACCESS_KEY: {{ pillar['s3.ket']['keyid'] }}
      - AWS_S3_SECRET_KEY: {{ pillar['s3.key'] }}
      - BROKER_URI: redis://172.17.0.1:6379/
      - EXPORT_BUCKET_NAME: thisissoon-fm
    - watch:
      - dockerng: .image
