#!stateconf yaml . jinja

#
# Ensure redis is installed
#

.redis:
  pkg.installed:
    - redis
  service.running:
  - enable: True
  - reload: True
  - watch:
    - pkg: .redis
