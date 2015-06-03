#!stateconf yaml . jinja

#
# Ensure mercurial is installed
#

.mercurial:
  pkg.installed:
    - name: mercurial
