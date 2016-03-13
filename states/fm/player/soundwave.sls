#!stateconf yaml . jinja

#
# Install and run Soundwave
#

# Dependencies
include:
  - libffi
  - git
  - mercurial
  - golang
  - libspotify
  - portaudio19-dev

# Get the Code
.get:
  cmd.run:
    - name: go get -u github.com/thisissoon/FM-SoundWave/cmd/soundwave
    - env:
      - GOPATH: /soundwave
    - require:
      - stateconf: git::goal
      - stateconf: mercurial::goal
      - stateconf: libffi::goal
      - stateconf: golang::goal
      - stateconf: libspotify::goal
      - stateconf: portaudio19-dev::goal

# Build the Package
.build:
  cmd.run:
    - name: go install github.com/thisissoon/FM-SoundWave/cmd/soundwave
    - env:
      - GOPATH: /soundwave
    - require:
      - cmd: .get

# Upstart Script
.init:
  file.managed:
    - name: /etc/init/soundwave.conf
    - source: salt://fm/player/files/soundwave.init.conf
    - mode: 644
    - template: jinja

.config:
  file.managed:
    - name: /etc/soundwave/config.yml
    - source: salt://fm/player/files/soundwave.config.yml
    - mode: 644
    - template: jinja
    - makedirs: True

# Upstart Service
.service:
  service.running:
    - name: soundwave
    - enable: True
    - require:
      - file: .init
      - cmd: .build
    - watch:
      - file: .init
      - file: .config
      - cmd: .build
