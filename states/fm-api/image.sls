#!stateconf yaml . jinja

#
# Download the soon/fm-api Image
#

# Pull latest Image
.image:
  docker.pulled:
    - name: quay.io/thisissoon/fm-api
    - tag: prod
    - force: true
    - require:
      - stateconf: docker::goal
