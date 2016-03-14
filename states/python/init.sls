#!stateconf yaml . jinja

#
# Ensure python and python-dev are installed
#

{% set python_venv_root = salt['pillar.get']('python:virtualenv:root', '/.virtualenvs') %}

# Install python and python-dev (curl also required)
.python:
  pkg.installed:
    - pkgs:
      - python
      - python-dev
      - curl

# Update Setup Tools
.setuptools:
  cmd.run:
    - name: curl -L https://bootstrap.pypa.io/ez_setup.py | python
    - unless: test -f /usr/local/bin/easy_install
    - reload_modules: True
    - require:
      - pkg: .python

# Install pip
.pip:
  cmd.run:
    - name: curl -L https://bootstrap.pypa.io/get-pip.py | python
    - unless: test -f /usr/local/bin/pip
    - reload_modules: True
    - require:
      - pkg: .python
      - cmd: .setuptools

# Install ipython globally
.ipython:
  pip.installed:
    - name: ipython
    - require:
      - cmd: .pip

# Instal pdbpp globally
.pdbpp:
  pip.installed:
    - name: pdbpp
    - require:
      - cmd: .pip

# Install Virtualenv
.virtualenv:
  pip.installed:
    - name: virtualenv
    - require:
      - cmd: .pip

# Virtualenvs Dir
.venvdir:
  file.directory:
    - name: {{ python_venv_root }}
    - makedirs: True
    - require:
      - pip: .virtualenv
