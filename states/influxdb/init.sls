#!stateconf yaml . jinja

.software-properties-common:
  pkg.installed

.influxdb:
  pkgrepo.managed:
    - humanname: InfluxDB
    - name: deb https://repos.influxdata.com/{{ salt['grains.get']('osfullname')|lower }} {{ salt['grains.get']('oscodename')|lower }} stable
    - key_url: https://repos.influxdata.com/influxdb.key
    - dist: {{ salt['grains.get']('oscodename')|lower }}
    - file: /etc/apt/sources.list.d/influxdb.list
    - require:
      - pkg: .software-properties-common
    - require_in:
      - pkg: .influxdb
  # Install the nginx package
  pkg.installed:
    - name: influxdb
