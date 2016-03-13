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
    - etcd
    - etcd.browser

  # FM Player
  'roles:fm-player':
    - match: grain
    - python
    - redis
    - fm.player.soundwave
    - fm.player.shockwave

  # FM API
  'roles:soon.fm.api':
    - match: grain
    - fm.api

  # FM Stats
  'roles:soon.fm.stats':
    - match: grain
    - fm.stats

  # FM Sockets
  'roles:soon.fm.websockets':
    - match: grain
    - fm.websockets

  # FM Frontend
  'roles:soon.fm.frontend':
    - match: grain
    - fm.frontend

  # Perceptor
  'roles:soon.fm.perceptor':
    - match: grain
    - fm.perceptor
