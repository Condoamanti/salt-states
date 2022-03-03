# module: packages: init
# state.apply packages
#
# Pillar:
# /packages/init.sls
#
# Description:
# Ensure common packages are installed/upgraded and configured
#
# Minion Requirements:
# - https://docs.saltproject.io/en/latest/ref/states/all/salt.states.module.html
{% set radarr_version = salt.pillar.get('chocolatey:source') %}

{% if pillar['packages'] %}
{% for item, v in pillar['packages'].items() %}
{% if grains ['os'] == 'Windows' %}
# Upgrade Windows packages here
upgrade-chocolatey_package_{{ item }}:
  module.run:
    - chocolatey.upgrade:
      - name: {{ item }}
      - source: {{ source }}
{% else %}
# Install linux packages here
{{ item }}: 
  pkg.installed: []
{% endif %}
{% endfor %}
{% endif %}