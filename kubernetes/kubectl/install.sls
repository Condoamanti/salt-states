# module: kubernetes.kubectl: install
# state.apply kubernetes.kubectl.install
#
# Pillar:
# /kubernetes/init.sls
#
# Description:
# Ensures kubectl is installed

{% set kubectl_version = salt.pillar.get('kubernetes:kubectl:version') %}

# Install kubectl package
install-kubectl_{{ kubectl_version }}:
  pkg.installed:
    - name: kubectl
    - version: {{ kubectl_version }}
    - require:
      - pkgrepo: kubernetes