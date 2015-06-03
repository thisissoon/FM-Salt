#!stateconf yaml . jinja

#
# Ensure git is installed
#

.git:
  pkg.installed:
    - name: git
