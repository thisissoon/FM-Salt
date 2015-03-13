#!stateconf yaml . jinja

#
# FM Player Salt States - Required for the player to run
#

include:
  # Dependencies
  - python
  - libffi
  - libasound2
  - libspotify
  - libevent

  # Install the player and the service
  - ..install
  - ..service
