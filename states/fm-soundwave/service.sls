#!stateconf yaml . jinja

#
# Install Upstart SoundWave Service
#

# Upstart Script
.init:
  file.managed:
    - name: /etc/init/soundwave.conf
    - source: salt://fm-soundwave/files/upstart.service.conf
    - mode: 644
    - template: jinja
    - context:
      SPOTIFY_USER: {{ pillar['spotify.user'] }}
      SPOTIFY_PASS: {{ pillar['spotify.pass'] }}
      SPOTIFY_KEY: /spotify.key
      REDIS_ADDRESS: redis.thisissoon.fm:6379
      REDIS_CHANNEL: fm:events
      REDIS_QUEUE: fm:player:queue

# Upstart Service
.service:
  service.running:
    - name: soundwave
    - enable: True
    - require:
      - file: .init
      - stateconf: .install::goal
    - watch:
      - file: .init
      - cmd: .install::build
