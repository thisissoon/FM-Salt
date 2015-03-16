#!stateconf yaml . jinja

#
# Nginx Configuraiton for Serving the API
#

.proxy:
  file.managed:
    - name: /etc/nginx/proxy.html
    - source: salt://fm-socket/files/proxy.html
    - mode: 644

.nginx:
  file.managed:
    - name: /etc/nginx/conf.d/api.thisissoon.fm.conf
    - source: salt://fm-api/files/api.thisissoon.fm.conf
    - mode: 644
    - template: jinja
    - require:
      - file: .proxy
    - watch_in:
      - service: nginx::nginx
