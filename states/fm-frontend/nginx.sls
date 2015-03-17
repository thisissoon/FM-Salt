#!stateconf yaml . jinja

#
# Nginx Configuraiton for Serving the Frontend
#

.nginx:
  file.managed:
    - name: /etc/nginx/conf.d/thisissoon.fm.conf
    - source: salt://fm-frontend/files/thisissoon.fm.conf
    - mode: 644
    - template: jinja
    - require:
      - stateconf: .container::goal
    - watch_in:
      - service: nginx::nginx
