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

  # FM Player
  'roles:fm-player':
    - match: grain
    - fm-player
