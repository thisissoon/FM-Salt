#!stateconf yaml . jinja

#
# Run the Celery API Container
#

# Pull latest Image
.pulled:
  docker.pulled:
    - name: quay.io/thisissoon/fm-stats
    - tag: prod
    - force: true
    - require:
      - stateconf: docker::goal

# Remove old contains if the image has changed
.remove-old:
  fm.remove_container_if_old:
    - container_id: fm-stats
    - image: quay.io/thisissoon/fm-stats
    - tag: prod
    - watch:
      - docker: .pulled

# Run the Installed Container
.running:
  docker.running:
    - name: fm-stats
    - image: quay.io/thisissoon/fm-stats:prod
    - environment:
      - AWS_S3_ACCESS_KEY: {{ pillar['s3']['key'] }}
      - AWS_S3_SECRET_KEY: {{ pillar['s3']['secret_key'] }}
      - BROKER_URI: redis://redis.thisissoon.fm:6379/
      - EXPORT_BUCKET_NAME: thisissoon-fm
    - require:
      - docker: .pulled

# Cleanup Old Images
.cleanup:
  fm.cleanup_docker_images
