#!stateconf yaml . jinja

#
# Run the API Container
#

{% set image = 'quay.io/thisissoon/fm-deepmind' %}
{% set tag = 'prod' %}

include:
  - docker

# Download latest image
.image:
  dockerng.image_present:
    - name: {{ image }}:{{ tag }}
    - force: True
    - require:
      - stateconf: docker::goal

# Run container
.container:
  dockerng.running:
    - name: soon.fm.deepmind
    - image: {{ image }}:{{ tag }}
    - restart_policy: always
    - environment:
      - USER_TOKEN: '{{ salt['pillar.get']('services:deepmind:user_token') }}'
      - EVENT_SERVICE: '{{ salt['pillar.get']('services:deepmind:event_service') }}'
      - SECRET: '{{ salt['pillar.get']('secrets:perceptor', 'n/a') }}'
      - DB: '{{ salt['pillar.get']('services:api:db', 'n/a') }}'
    - watch:
      - dockerng: .image
