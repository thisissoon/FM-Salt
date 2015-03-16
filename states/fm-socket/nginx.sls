#!stateconf yaml . jinja

#
# Nginx Configuraiton for Serving the Web Socket
#

.proxy:
  file.managed:
    - name: /etc/nginx/proxy.html
    - source: salt://fm-socket/files/proxy.html
    - mode: 644

.nginx:
  file.managed:
    - name: /etc/nginx/conf.d/socket.thisissoon.fm.conf
    - source: salt://fm-socket/files/socket.thisissoon.fm.conf
    - mode: 644
    - template: jinja
    - require:
      - file: .proxy
    - watch_in:
      - service: nginx::nginx
