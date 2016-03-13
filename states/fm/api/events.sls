#!stateconf yaml . jinja

#
# Run the Events Container
#

{% set image = 'quay.io/thisissoon/fm-api' %}
{% set tag = 'prod' %}

include:
  - docker
  - redis

# Get the latest image
.image:
  dockerng.image_present:
    - name: {{ image }}:{{ tag }}
    - force: True
    - require:
      - stateconf: docker::goal

# Create Container
.container:
  dockerng.running:
    - name: soon.fm.events
    - image: {{ image }}:{{ tag }}
    - restart_policy: always
    - command: ./manage.py runeventlistener
    - environment:
      - SERVER_NAME: {{ salt['pillar.get']('services:api:server_name', 'api.thisissoon.fm') }}
      - GUNICORN_HOST: 0.0.0.0
      - GUNICORN_PORT: '5000'
      - GUNICORN_WORKERS: '8'
      - FM_SETTINGS_MODULE: fm.config.default
      - REDIS_SERVER_URI: redis://172.17.0.1:6379/
      - CELERY_BROKER_URL: redis://172.17.0.1:6379/0
      - REDIS_DB: '0'
      - REDIS_CHANNEL: fm:events
      - SQLALCHEMY_DATABASE_URI: {{ salt['pillar.get']('services:api:db', 'n/a') }}
      - GOOGLE_CLIENT_ID: {{ salt['pillar.get']('google:client:id', 'n/a') }}
      - GOOGLE_CLIENT_SECRET: {{ salt['pillar.get']('google:client:secret', 'n/a') }}
      - GOOGLE_REDIRECT_URI: {{ salt['pillar.get']('services:api:google:redirect', 'https://thisissoon.fm/') }}
      - ECHONEST_API_KEY: {{ salt['pillar.get']('echonest:key', 'n/a') }}
      - CORS_ACA_ORIGIN: {{ salt['pillar.get']('services:api:cors_aca_origin', 'https://thisissoon.fm') }}
    - watch:
      - dockerng: .image
    - require:
      - stateconf: redis::goal
