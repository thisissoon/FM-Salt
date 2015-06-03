#!stateconf yaml . jinja

#
# Ensure portaudio19-dev is installed
#

.portaudio19-dev:
  pkg.installed:
    - name: portaudio19-dev
