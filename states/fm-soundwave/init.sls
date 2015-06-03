#!stateconf yaml . jinja

#
# FM SoundWave Salt States
#

include:
  # Dependencies
  - libffi
  - golang
  - libspotify
  - portaudio19-dev

  # Install the player and the service
  - ..install
