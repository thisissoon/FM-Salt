#!stateconf yaml . jinja

#
# Download the soon/fm-slack Container
#

# Pull latest Image
.image:
  docker.pulled:
    - name: soon/fm-slack
    - tag: latest
    - force: true
    - require:
      - stateconf: docker::goal

# Remove old contains if the image has changed
.remove-old:
  fm.remove_container_if_old:
    - container_id: fm-slack
    - image: soon/fm-slack
    - tag: latest
    - watch:
      - docker: .image

# Create Container
.container:
  docker.installed:
    - name: fm-slack
    - image: soon/fm-slack:latest
    - environment:
      - FM_SLACK_LOG_LEVEL: DEBUG
      - FM_SLACK_REDIS_URI: redis://redis.thisissoon.fm:6379/
      - FM_SLACK_REDIS_CHANNEL: fm:events
      - FM_SLACK_SLACK_WEBHOOK_URL: {{ pillar['slack.webhook'] }}
      - FM_SLACK_API_URL: http://api.thisissoon.fm
    - require:
      - docker: .image

# Run the Installed Container
.running:
  docker.running:
    - name: fm-slack
    - require:
      - docker: .container

# Cleanup Old Images
.cleanup:
  fm.cleanup_docker_images
