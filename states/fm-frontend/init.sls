#!stateconf yaml . jinja

#
# States for running the FM Frontend Client Service
# This uses docker to run the actual application.
#

include:
  - docker
  - redis
  - nginx

  - ..container
  - ..nginx
