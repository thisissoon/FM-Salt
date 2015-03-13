#!stateconf yaml . jinja

#
# Install Nginx
#

include:
  - python-software-properties

# Upstart Config
.upstart:
  file.managed:
    - name: /etc/init/nginx.conf
    - source: salt://nginx/files/nginx.upstart.conf
    - mode: 644

# Install Nginx
.nginx:
  user.present:
    - name: nginx
  pkgrepo.managed:
    - ppa: nginx/stable
    - require:
      - stateconf: python-software-properties::goal
  pkg.installed:
    - name: nginx
    - require:
      - pkgrepo: .nginx
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://nginx/files/nginx.conf
    - mode: 644
    - require:
      - pkg: .nginx
  service.running:
    - name: nginx
    - enable: True
    - reload: True
    - require:
      - file: .upstart
      - user: .nginx
    - watch:
      - file: .nginx
      - pkg: .nginx
