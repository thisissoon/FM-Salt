#!stateconf yaml . jinja

#
# Install Upstart Player Service
#

# Upstart Script
.init:
  file.managed:
    - name: /etc/init/fm-player.conf
    - source: salt://fm-player/files/upstart.service.conf
    - mode: 644
    - template: jinja
    - context:
      SPOTIFY_USER: {{ pillar['spotify.user'] }}
      SPOTIFY_PASS: {{ pillar['spotify.pass'] }}
      REDIS_URI: redis://redis.thisissoon.fm:6379/
      REDIS_DB: 0
      REDIS_CHANNEL: fm:events
      MIXER_NAME: 'Digital'

# Upstart Service
.service:
  service.running:
    - name: fm-player
    - enable: True
    - require:
      - file: .init
      - stateconf: .install::goal
    - watch:
      - file: .init
      - pip: .install::fm-player
