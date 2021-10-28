# module: packages: init
# state.apply packages
#
# Pillar:
# /packages/init.sls
#
# Description:
# Ensure common packages are installed and configured
#
# Minion Requirements:
# - https://docs.saltproject.io/en/latest/ref/states/all/salt.states.module.html

{% if pillar['packages'] %}
{% for item, v in pillar['packages'].items() %}
{% if grains ['os'] == 'Windows' %}
# Install Windows packages here
install-chocolatey_package_{{item}}:
  module.run:
    - chocolatey.install:
      - name: {{ item }}
{% else %}
# Install linux packages here
{{ item }}: 
  pkg.installed: []
{% endif %}
{% endfor %}
{% endif %}