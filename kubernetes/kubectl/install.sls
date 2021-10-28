# module: kubernetes.kubectl: install
# state.apply kubernetes.kubectl.install
#
# Description:
# Ensures kubectl is installed

# Install kubectl package
install-kubectl:
  pkg.installed:
    - name: kubectl
    - version: 1.22.3
    - require:
      - file: /etc/yum.repos.d/kubernetes.repo