#!stateconf yaml . jinja

#
# States for running the FM API Service
# This uses docker to run the actual application.
#

include:
  - docker
  - redis
  - nginx

  - ..container
  - ..nginx
