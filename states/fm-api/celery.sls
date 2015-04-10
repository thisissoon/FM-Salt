#!stateconf yaml . jinja

#
# Run the Celery API Container
#

# Remove old contains if the image has changed
.remove-old:
  fm.remove_container_if_old:
    - container_id: fm-api-celery
    - image: soon/fm-api
    - tag: latest
    - watch:
      - docker: .image::image

# Create Container
.container:
  docker.installed:
    - name: fm-api-celery
    - image: soon/fm-api:latest
    - ports:
      - 5000/tcp
    - command: celery -A fm.tasks.app worker -l info -c 12
    - environment:
      - SERVER_NAME: api.thisissoon.fm
      - GUNICORN_HOST: 0.0.0.0
      - GUNICORN_PORT: 5000
      - GUNICORN_WORKERS: 8
      - FM_SETTINGS_MODULE: fm.config.default
      - REDIS_SERVER_URI: redis://redis.thisissoon.fm:6379/
      - REDIS_DB: 0
      - REDIS_CHANNEL: fm:events
      - SQLALCHEMY_DATABASE_URI: {{ pillar['rds.uri'] }}
      - GOOGLE_CLIENT_ID: {{ pillar['google.client.id'] }}
      - GOOGLE_CLIENT_SECRET: {{ pillar['google.client.secret'] }}
      - GOOGLE_REDIRECT_URI: https://thisissoon.fm/
      - CORS_ACA_ORIGIN: https://thisissoon.fm
    - require:
      - docker: .image::image

# Run the Installed Container
.running:
  docker.running:
    - name: fm-api-celery
    - require:
      - docker: .container

# Cleanup Old Images
.cleanup:
  fm.cleanup_docker_images
