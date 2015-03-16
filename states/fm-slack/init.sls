#!stateconf yaml . jinja

#
# States for running the FM Slack Service
# This uses docker to run the actual application.
#

include:
  - docker
  - redis

  - ..container
