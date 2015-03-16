#!stateconf yaml . jinja

#
# Nginx Configuraiton for Serving the Web Socket
#

.nginx:
  file.managed:
    - name: /etc/nginx/conf.d/socket.thisissoon.fm.conf
    - source: salt://fm-socket/files/socket.thisissoon.fm.conf
    - mode: 644
    - template: jinja
    - watch_in:
      - service: nginx::nginx
