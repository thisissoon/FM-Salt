#!stateconf yaml . jinja

#
# Download the soon/fm-api Container
#

.image:
  docker.pulled:
    - name: soon/fm-api
    - tag: latest
    - force: true
    - require:
      - stateconf: docker::goal
