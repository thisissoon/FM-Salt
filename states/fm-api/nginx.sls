#!stateconf yaml . jinja

#
# Nginx Configuraiton for Serving the API
#

.nginx:
  file.managed:
    - name: /etc/nginx/conf.d/api.thisissoon.fm.conf
    - source: salt://fm-api/files/api.thisissoon.fm.conf
    - mode: 644
    - template: jinja
    - watch_in:
      - service: nginx::nginx
