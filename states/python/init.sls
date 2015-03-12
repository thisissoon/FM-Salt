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

.pip:
  cmd.run:
    - name: curl -L https://bootstrap.pypa.io/get-pip.py | python
    - unless: test -f /usr/local/bin/pip
    - reload_modules: True
    - require:
      - pkg: .python-dev
