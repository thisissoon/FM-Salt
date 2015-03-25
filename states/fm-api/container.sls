#!stateconf yaml . jinja

#
# Download the soon/fm-api Container
#

# Pull latest Image
.image:
  docker.pulled:
    - name: soon/fm-api
    - tag: latest
    - force: true
    - require:
      - stateconf: docker::goal

# Remove old contains if the image has changed
.remove-old:
  fm.remove_container_if_old:
    - container_id: fm-api
    - image: soon/fm-api
    - tag: latest
    - watch:
      - docker: .image

# Create Container
.container:
  docker.installed:
    - name: fm-api
    - image: soon/fm-api:latest
    - ports:
      - 5000/tcp
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
    - require:
      - docker: .image

# Run the Installed Container
.running:
  docker.running:
    - name: fm-api
    - require:
      - docker: .container

# Cleanup Old Images
.cleanup:
  fm.cleanup_docker_images

# Run DB Migrations on changes to the container
.migrate:
  cmd.wait:
    - name: docker exec fm-api manage.py db upgrade
    - watch:
      - docker: .running
