#!stateconf yaml . jinja

#
# Installation of apt-transport-https
#

.apt-transport-https:
  pkg.installed:
    - name: apt-transport-https
