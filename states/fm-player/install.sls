#!stateconf yaml . jinja

#
# Installs Dependant Packages
#

.fm-player:
  pip.installed:
    - name: git+https://github.com/thisissoon/FM-Player.git@master
    - require:
      - stateconf: python::goal

.spotify-key:
  file.managed:
    - name: /spotify.key
    - source: s3://thisissoon-fm.s3.amazonaws.com/soon_spotify.key
