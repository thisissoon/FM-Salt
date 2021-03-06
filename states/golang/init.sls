#!stateconf yaml . jinja

#
# Ensure golang is installed
#

.key:
  cmd.run:
    - name: wget https://xivilization.net/~marek/raspbian/xivilization-raspbian.gpg.key -O - | sudo apt-key add -

.list:
  cmd.run:
    - name: wget https://xivilization.net/~marek/raspbian/xivilization-raspbian.list -O /etc/apt/sources.list.d/xivilization-raspbian.list
    - require:
      - cmd: .key

.golang:
  pkg.installed:
    - name: golang
