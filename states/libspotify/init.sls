#!stateconf yaml . jinja

#
# Install libspotify-dev from Mopidy
#

.mopidy:
  pkgrepo.managed:
    - name: deb http://apt.mopidy.com/ stable main contrib non-free
    - key_url: https://apt.mopidy.com/mopidy.gpg
    - file: /etc/apt/sources.list.d/mopidy.list
    - require_in:
      - pkg: .libspotify-dev

.libspotify-dev:
  pkg.installed:
    - name: libspotify-dev
