#!stateconf yaml . jinja

#
# Ensure g++ is installed
#

.g++:
  pkg.installed:
    - name: g++
