#!stateconf yaml . jinja

#
# Run the Celery API Container
#

{% set image = 'quay.io/thisissoon/fm-api' %}
{% set tag = 'prod' %}

include:
  - docker
  - redis

.image:
  dockerng.image_present:
    - name: {{ image }}:{{ tag }}
    - force: True
    - require:
      - stateconf: docker::goal

.container:
  dockerng.running:
    - name: soon.fm.celery
    - image: {{ image }}:{{ tag }}
    - restart_policy: always
    - command: celery -A fm.tasks.app worker -l info -c 12
    - environment:
      - C_FORCE_ROOT: true
      - FM_SETTINGS_MODULE: fm.config.default
      - REDIS_SERVER_URI: redis://172.17.0.1:6379/
      - CELERY_BROKER_URL: redis://172.17.0.1:6379/0
      - REDIS_DB: 0
      - REDIS_CHANNEL: fm:events
      - SQLALCHEMY_DATABASE_URI: {{ salt['pillar.get']('services:api:db') }}
      - GOOGLE_CLIENT_ID: {{ salt['pillar.get']('google:client:id') }}
      - GOOGLE_CLIENT_SECRET: {{ salt['pillar.get']('google:client:secret') }}
      - ECHONEST_API_KEY: {{ salt['pillar.get']('echonest:key') }}
    - watch:
      - dockerng: .image
    - require:
      - stateconf: redis::goal
