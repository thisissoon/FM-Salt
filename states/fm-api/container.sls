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

# Create Container
.container:
  docker.installed:
    - name: fm-api
    - image: soon/fm-api:latest
    - ports:
      - 5000/tcp
    - environment:
      - GUNICORN_HOST: 0.0.0.0
      - GUNICORN_PORT: 5000
      - GUNICORN_WORKERS: 8
      - FM_SETTINGS_MODULE: fm.config.production
      - REDIS_SERVER_URI: redis://redis.thisissoon.fm/6379
      - REDIS_DB: 0
      - REDIS_CHANNEL: fm:events
      - SQLALCHEMY_DATABASE_URI: {{ pillar['rds.uri'] }}
    - require:
      - docker: .image

# Run the Installed Container
.running:
  docker.running:
    - name: fm-api
    - ports:
      - "5000/tcp":
        HostIp: ""
        HostPort: "5000"
    - require:
      - docker: .container

# Run DB Migrations on changes to the container
.migrate:
  cmd.wait:
    - name: docker exec fm-api manage.py db upgrade
    - watch:
      - docker: .running
