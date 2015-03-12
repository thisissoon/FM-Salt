#!stateconf yaml . jinja

#
# Ensure libffi-dev is installed
#

.libffi-dev:
  pkg.installed:
    - name: libffi-dev
