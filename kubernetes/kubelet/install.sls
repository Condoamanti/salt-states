# module: kubernetes.kubelet: install
# state.apply kubernetes.kubelet.install
#
# Pillar:
# /kubernetes/init.sls
#
# Description:
# Ensures kubelet is installed

{% set kubelet_version = salt.pillar.get('kubernetes:kubelet:version') %}

# Install kubectl package
install-kubelet_{{ kubelet_version }}:
  pkg.installed:
    - name: kubelet
    - version: {{ kubelet_version }}
    - require:
      - pkgrepo: kubernetes