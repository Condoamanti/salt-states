# module: chocolatey: install
# state.apply chocolatey.install
#
# Description:
# Ensures chocolatey is installed
#
# Module Information:
# - https://docs.saltproject.io/en/latest/ref/modules/all/salt.modules.chocolatey.html
#
# Minion Requirements:
# - https://docs.saltproject.io/en/latest/ref/states/all/salt.states.module.html

{% if not salt['file.directory_exists']('C:\ProgramData\Chocolatey') %}
install-chocolatey:
  module.run:
    - chocolatey.bootstrap:
{% else %}
output-chocolatey_version:
  module.run:
    - chocolatey.chocolatey_version:
{% endif %}