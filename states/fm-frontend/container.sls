#!stateconf yaml . jinja

#
# Download the soon/fm-frontend Container
#

# Pull latest Image
.image:
  docker.pulled:
    - name: quay.io/thisissoon/fm-frontend
    - tag: latest
    - force: true
    - require:
      - stateconf: docker::goal

# Remove old contains if the image has changed
.remove-old:
  fm.remove_container_if_old:
    - container_id: fm-frontend
    - image: soon/fm-frontend
    - tag: latest
    - watch:
      - docker: .image

# Create Container
.container:
  docker.installed:
    - name: fm-frontend
    - image: soon/fm-frontend:latest
    - ports:
      - 80/tcp
    - require:
      - docker: .image

# Run the Installed Container
.running:
  docker.running:
    - name: fm-frontend
    - require:
      - docker: .container

# Cleanup Old Images
.cleanup:
  fm.cleanup_docker_images
