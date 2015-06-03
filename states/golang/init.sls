#!stateconf yaml . jinja

#
# Ensure golang is installed
#

.golang:
  pkg.installed:
    - name: golang
