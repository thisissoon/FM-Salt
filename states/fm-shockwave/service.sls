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

.config:
  file.managed:
    - name: /etc/shockwave/config.yml
    - source: salt://fm-shockwave/files/config.yml
    - mode: 644
    - template: jinja
    - makedirs: True

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
      - file: .config
      - cmd: .install::build
