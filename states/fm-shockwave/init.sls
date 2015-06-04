#!stateconf yaml . jinja

#
# FM Shockwave Salt States
#

include:
  # Dependencies
  - libffi
  - git
  - mercurial
  - golang
  - libspotify
  - libasound2
  - g++

  # Install the player and the service
  - ..install
  #- ..service
