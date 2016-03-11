#!stateconf yaml . jinja

#
# Ensure redis is installed
#

include:
  - python

# OS Level Dependencies
.dependencies:
  pkg.installed:
    - pkgs:
      - software-properties-common

# Installs, Configures, and runs Redis in one State
.redis:
  pkgrepo.managed:
    - ppa: chris-lea/redis-server
    - require:
      - pkg: .dependencies
  pkg.installed:
    - name: redis-server
    - require:
      - pkgrepo: .redis
    - watch_in:
      - service: .redis
  file.managed:
    - name: /etc/redis/redis.conf
    - source: salt://redis/files/redis.conf
    - require:
      - pkg: .redis
    - watch_in:
      - service: .redis
  service.running:
    - name: redis-server
    - enable: True
    - relaod: True
    - require:
      - pkg: .redis
  pip.installed:
    - name: redis
    - require:
      - stateconf: python::goal
      - pkg: .redis
