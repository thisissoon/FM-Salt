#!stateconf yaml . jinja

#
# Installation of python-software-properties
#

.apt-transport-https:
  pkg.installed:
    - name: python-software-properties
