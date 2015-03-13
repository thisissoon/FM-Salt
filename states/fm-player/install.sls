#!stateconf yaml . jinja

#
# Installs Dependant Packages
#

# Install the player from GitHub
.fm-player:
  pip.installed:
    - name: git+https://github.com/thisissoon/FM-Player.git@master
    - require:
      - stateconf: python::goal

# Download the Spotify Key from S3
.spotify-key:
  module.run:
    - name: s3.get
    - bucket: thisissoon-fm
    - path: soon_spotify.key
    - local_file: /spotify.key
    - bin: True
