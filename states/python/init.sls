#!stateconf yaml . jinja

#
# Ensure python and python-dev are installed
#

.python:
  pkg.installed:
    - name: python

.python-dev:
  pkg.installed:
    - name: python-dev
    - require:
      - pkg: .python
