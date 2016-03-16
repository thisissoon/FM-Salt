#!stateconf yaml . jinja

#
# Install Nginx
#

.software-properties-common:
  pkg.installed

# Installs, Configures, and runs Nginx in one State
.nginx:
  # Create an nginx user
  user.present:
    - name: nginx
  # Add the nginx PPA to install the latest stable version
  pkgrepo.managed:
    - ppa: nginx/stable
    - require:
      - pkg: .software-properties-common
  # Install the nginx package
  pkg.installed:
    - name: nginx
    - require:
      - pkgrepo: .nginx
  # Replace the nginx config with our own
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://nginx/files/nginx.conf
    - template: jinja
    - mode: 644
    - user: nginx
    - group: nginx
    - require:
      - pkg: .nginx
  # Manage Snippets Directory
  file.recurse:
    - name: /etc/nginx/snippets
    - source: salt://nginx/files/snippets
    - template: jinja
    - require:
      - pkg: .nginx
  # Run the Nginx Service
  service.running:
    - name: nginx
    - enable: true
    - reload: true
    - require:
      - user: .nginx
    # Restart the service whenever the config or package changes
    - watch:
      - file: .nginx
      - pkg: .nginx
