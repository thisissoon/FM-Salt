#!stateconf yaml . jinja

#
# Install FM-Shockwave
#

.get:
  cmd.run:
    - name: go get github.com/thisissoon/FM-Shockwave/...
    - env:
      - GOPATH: /soundwave
    - require:
      - stateconf: git::goal
      - stateconf: mercurial::goal
      - stateconf: g++::goal
      - stateconf: libffi::goal
      - stateconf: golang::goal
      - stateconf: libspotify::goal
      - stateconf: libasound2::goal

.build:
  cmd.run:
    - name: go install github.com/thisissoon/FM-Shockwave/...
    - env:
      - GOPATH: /shockwave
    - require:
      - cmd: .get
