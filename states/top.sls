#
# Root State Top File
#
# This file is responsible for assigning state formulae to
# specific salt minions. Read more on targeting minions here:
#
# http://docs.saltstack.com/en/latest/topics/targeting/
#

base:

  # API Servers
  '*':
    - core

  'roles:salt-master':
    - match: grain
    - python
    - redis

  # FM Player
  'roles:fm-player':
    - match: grain
    - openvpn
    - fm-soundwave
    - fm-shockwave

  # FM API
  'roles:fm-api':
    - match: grain
    - fm-api

  # FM Sockets
  'roles:fm-socket':
    - match: grain
    - fm-socket

  # FM Slack
  'roles:fm-slack':
    - match: grain
    - fm-slack

  # FM Frontend
  'roles:fm-frontend':
    - match: grain
    - fm-frontend

  'roles:fm-redis'
    - match: grain
    - redis
