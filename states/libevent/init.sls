#!stateconf yaml . jinja

#
# Install libevent-dev is Installed
#

.libevent-dev:
  pkg.installed:
    - name: libevent-dev
