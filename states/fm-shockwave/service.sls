#!stateconf yaml . jinja

#
# Install Upstart Shockwave Service
#

# Upstart Script
.init:
  file.managed:
    - name: /etc/init/shockwave.conf
    - source: salt://fm-shockwave/files/upstart.service.conf
    - mode: 644
    - template: jinja
    - context:
      REDIS_ADDRESS: redis.thisissoon.fm:6379
      REDIS_CHANNEL: fm:events
      MAX_VOLUME: 70
      MIN_VOLUME: 16
      MIXER: Digital

# Upstart Service
.service:
  service.running:
    - name: shockwave
    - enable: True
    - require:
      - file: .init
      - stateconf: .install::goal
    - watch:
      - file: .init
      - cmd: .install::build
