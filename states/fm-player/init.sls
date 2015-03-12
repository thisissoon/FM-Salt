#!stateconf yaml . jinja

#
# FM Player Salt States - Required for the player to run
#

include:
  - libffi
  - libasound2
  - libspotify
  - libevent
