#!stateconf yaml . jinja

#
# FM-Perceptor Deployment via Docker
#

# Pull Production Image
.image:
  docker.pulled:
    - name: soon/fm-perceptor
    - tag: prod
    - force: true
    - require:
      - stateconf: docker::goal

# Remove old contains if the image has changed
.remove-old:
  fm.remove_container_if_old:
    - container_id: fm-perceptor
    - image: soon/fm-perceptor
    - tag: prod
    - watch:
      - docker: .image

.config:
  file.managed:
    - name: /etc/perceptor/perceptor.yml
    - source: salt://fm-perceptor/files/perceptor.yml
    - makedirs: True
    - template: jinja

# Create Container
.container:
  docker.installed:
    - name: fm-perceptor
    - image: soon/fm-perceptor:prod
    - ports:
      - 9000/tcp
    - volumes:
      - /etc/perceptor
    - require:
      - docker: .image
      - file: .config

# Run the Installed Container
.running:
  docker.running:
    - name: fm-perceptor
    - volumes:
      - /etc/perceptor: /etc/perceptor
    - require:
      - docker: .container
    - watch:
      - file: .config

# Cleanup Old Images
.cleanup:
  fm.cleanup_docker_images

# Nginx Configuration
.nginx:
  file.managed:
    - name: /etc/nginx/conf.d/perceptor.thisissoon.fm.conf
    - source: salt://fm-perceptor/files/perceptor.thisissoon.fm.conf
    - mode: 644
    - template: jinja
    - require:
      - docker: .running
    - watch_in:
      - service: nginx::nginx
