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

.config:
  file.managed:
    - name: /etc/soundwave/config.yml
    - source: salt://fm-soundwave/files/config.yml
    - mode: 644
    - template: jinja
    - makedirs: True

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
      - file: .config
      - cmd: .install::build
