#!stateconf yaml . jinja

#
# Installs Dependant Packages
#

.fm-player:
  pip.installed:
    - name: git+https://github.com/thisissoon/FM-Player.git
    - require:
      - stateconf: python::goal
