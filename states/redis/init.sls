#!stateconf yaml . jinja

#
# Ensure redis is installed
#

.redis:
  pkg.installed:
    - name: redis-server
  service.running:
    - name: redis-server
    - enable: True
    - reload: True
    - watch:
      - pkg: .redis
