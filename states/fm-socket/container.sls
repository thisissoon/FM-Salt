#!stateconf yaml . jinja

#
# Download the soon/fm-socket Container
#

# Pull latest Image
.image:
  docker.pulled:
    - name: soon/fm-socket
    - tag: latest
    - force: true
    - require:
      - stateconf: docker::goal

# Remove old contains if the image has changed
.remove-old:
  fm.remove_container_if_old:
    - container_id: fm-socket
    - image: soon/fm-socket
    - tag: latest
    - watch:
      - docker: .image

# Create Container
.container:
  docker.installed:
    - name: fm-socket
    - image: soon/fm-socket:latest
    - ports:
      - 6000/tcp
    - environment:
      - SOCKET_PORT: 6000
      - SOCKET_LOG_LEVEL: 'info'
      - REDIS_URI: redis://redis.thisissoon.fm:6379/
      - REDIS_CHANNEL: fm:events
    - require:
      - docker: .image

# Run the Installed Container
.running:
  docker.running:
    - name: fm-socket
    - port_bindings:
        "6000/tcp":
            HostIp: ""
            HostPort: "6000"
    - require:
      - docker: .container

# Cleanup Old Images
.cleanup:
  fm.cleanup_docker_images
