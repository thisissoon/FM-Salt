#!stateconf yaml . jinja

#
# Install FM-SoundWave
#

.spotify-key:
  module.run:
    - name: s3.get
    - bucket: thisissoon-fm
    - path: soon_spotify.key
    - local_file: /spotify.key
    - bin: True

.get:
  cmd.run:
    - name: go get github.com/thisissoon/FM-SoundWave/cmd
    - env:
      - GOPATH: /soundwave
    - require:
      - stateconf: libffi::goal
      - stateconf: golang::goal
      - stateconf: libspotify::goal
      - stateconf: portaudio19-dev::goal

.build:
  cmd.run:
    - name: go build -o /usr/local/bin/soundwave github.com/thisissoon/FM-SoundWave/cmd
    - env:
      - GOPATH: /soundwave
    - require:
      - cmd: .get
