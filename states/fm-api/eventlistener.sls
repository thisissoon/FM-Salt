#!stateconf yaml . jinja

#
# Run the API Container
#

# Remove old contains if the image has changed
.remove-old:
  fm.remove_container_if_old:
    - container_id: fm-api-events
    - image: soon/fm-api
    - tag: latest
    - watch:
      - docker: .image::image

# Create Container
.container:
  docker.installed:
    - name: fm-api-events
    - image: soon/fm-api:latest
    - ports:
      - 5000/tcp
    - environment: __salt__['fm.api_env']()
    - require:
      - docker: .image::image

# Run the Installed Container
.running:
  docker.running:
    - name: fm-api-events
    - command: manage.py runeventlistener
    - require:
      - docker: .container

# Cleanup Old Images
.cleanup:
  fm.cleanup_docker_images
