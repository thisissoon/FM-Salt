#!stateconf yaml . jinja

#
# Ensure redis is installed
#

.redis:
  pkg.installed:
    - name: redis
  service.running:
    - name: redis
    - enable: True
    - reload: True
    - watch:
      - pkg: .redis
