# module: kubernetes.kubectl: init
# state.apply kubernetes.kubectl
#
# Description:
# Base init for kubernetes.kubectl state

include:
  - kubernetes.kubectl.install