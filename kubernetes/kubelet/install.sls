# module: kubernetes.kubelet: install
# state.apply kubernetes.kubelet.install
#
# Description:
# Ensures kubelet is installed

# Install kubectl package
install-kubelet:
  pkg.installed:
    - name: kubelet
    #- version: 1.22.3
    - require:
      - file: /etc/yum.repos.d/kubernetes.repo