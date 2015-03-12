#!stateconf yaml . jinja

#
# Install libevent is Installed
#

.libevent-dev:
  pkg.installed:
    - name: libevent-dev
