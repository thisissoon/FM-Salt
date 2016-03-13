#!stateconf yaml . jinja

#
# Install and run Shockwave
#

# Dependencies
include:
  - libffi
  - git
  - mercurial
  - golang
  - libspotify
  - libasound2
  - g++

# Get the code
.get:
  cmd.run:
    - name: go get -u github.com/thisissoon/FM-Shockwave/...
    - env:
      - GOPATH: /shockwave
    - require:
      - stateconf: git::goal
      - stateconf: mercurial::goal
      - stateconf: g++::goal
      - stateconf: libffi::goal
      - stateconf: golang::goal
      - stateconf: libspotify::goal
      - stateconf: libasound2::goal

# Buidl the application
.build:
  cmd.run:
    - name: go install github.com/thisissoon/FM-Shockwave/cmd/shockwave
    - env:
      - GOPATH: /shockwave
    - require:
      - cmd: .get

# Upstart Script
.init:
  file.managed:
    - name: /etc/init/shockwave.conf
    - source: salt://fm/player/files/shockwave.init.conf
    - mode: 644
    - template: jinja

# Config
.config:
  file.managed:
    - name: /etc/shockwave/config.yml
    - source: salt://fm/player/files/shockwave.config.yml
    - mode: 644
    - template: jinja
    - makedirs: True

# Upstart Service
.service:
  service.running:
    - name: shockwave
    - enable: True
    - require:
      - file: .init
      - cmd: .build
    - watch:
      - file: .init
      - file: .config
      - cmd: .build
