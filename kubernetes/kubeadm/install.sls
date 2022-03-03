# module: kubernetes.kubeadm: install
# state.apply kubernetes.kubeadm.install
#
# Pillar:
# /kubernetes/init.sls
#
# Description:
# Ensures kubeadm is installed

{% set kubeadm_version = salt.pillar.get('kubernetes:kubeadm:version') %}

# Install kubeadm package
install-kubeadm_{{ kubeadm_version }}:
  pkg.installed:
    - name: kubeadm
    - version: {{ kubeadm_version }}
    - require:
      - pkgrepo: kubernetes