# module: kubernetes.kubelet: init
# state.apply kubernetes.kubelet
#
# Description:
# Base init for kubernetes.kubelet state

include:
  - kubernetes.kubelet.install