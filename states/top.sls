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
    - fm-player

  # FM API
  'roles:fm-api':
    - match: grain
    - fm-api
