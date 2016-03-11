#!stateconf yaml . jinja

#
# Run the API Container
#

{% set image = 'quay.io/thisissoon/fm-api' %}
{% set tag = 'prod' %}
{% set port = 34000 %}

include:
  - docker
  - nginx
  - redis

# Download latest image
.image:
  dockerng.image_present:
    - name: {{ image }}:{{ tag }}
    - force: True
    - require:
      - stateconf: docker::goal

# Run container
.container:
  dockerng.running:
    - name: soon.fm.api
    - image: {{ image }}:{{ tag }}
    - restart_policy: always
    - port_bindings:
      - {{ port }}:5000
    - environment:
      - SERVER_NAME: {{ salt['pillar.get']('services:api:server_name', 'api.thisissoon.fm') }}
      - GUNICORN_HOST: 0.0.0.0
      - GUNICORN_PORT: 5000
      - GUNICORN_WORKERS: 8
      - FM_SETTINGS_MODULE: fm.config.default
      - REDIS_SERVER_URI: redis://172.17.0.1:6379/
      - CELERY_BROKER_URL: redis://172.17.0.1:6379/0
      - REDIS_DB: 0
      - REDIS_CHANNEL: fm:events
      - SQLALCHEMY_DATABASE_URI: {{ salt['pillar.get']('services:api:db') }}
      - GOOGLE_CLIENT_ID: {{ salt['pillar.get']('google:client:id') }}
      - GOOGLE_CLIENT_SECRET: {{ salt['pillar.get']('google:client:secret') }}
      - GOOGLE_REDIRECT_URI: {{ salt['pillar.get']('services:api:google:redirect', 'https://thisissoon.fm/') }}
      - ECHONEST_API_KEY: {{ salt['pillar.get']('echonest:key') }}
      - CORS_ACA_ORIGIN: {{ salt['pillar.get']('services:api:cors_aca_origin', 'https://thisissoon.fm') }}
    - watch:
      - dockerng: .image
    - require:
      - stateconf: redis::goal

# Run DB Migrations on changes to the container
.migrate:
  cmd.wait:
    - name: docker exec fm-api ./manage.py db upgrade
    - watch:
      - dockerng: .container

# Nginx Configuration for FE Proxy
.proxy:
  file.managed:
    - name: /etc/nginx/proxy.html
    - source: salt://fm-api/files/proxy.html
    - mode: 644

# Nginx Configuration
.nginx:
  file.managed:
    - name: /etc/nginx/conf.d/api.thisissoon.fm.conf
    - source: salt://fm-api/files/api.thisissoon.fm.conf
    - mode: 644
    - template: jinja
    - conext:
      port: {{ port }}
      server_name: {{ server_name }}
    - require:
      - dockerng: .container
    - watch_in:
      - service: nginx::nginx
