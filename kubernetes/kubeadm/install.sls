# module: kubernetes.kubeadm: install
# state.apply kubernetes.kubeadm.install
#
# Description:
# Ensures kubeadm is installed

# Install kubeadm package
install-kubeadm:
  pkg.installed:
    - name: kubeadm
    - version: 1.22.3
    - require:
      - file: /etc/yum.repos.d/kubernetes.repo