# module: kubernetes: install
# state.apply kubernetes.install
#
# Description:
# Ensures kubernetes is installed

include:
  - kubernetes.kubelet.init
  - kubernetes.kubeadm.init
  - kubernetes.kubectl.init
  - kubernetes.cri-o.init

# Create repository file for kubernetes
create-/etc/yum.repos.d/kubernetes.repo:
  file.managed:
    - name:  /etc/yum.repos.d/kubernetes.repo
    - source: salt://files/linux/rhel/etc/yum.repos.d/kubernetes.repo
    - user:  root
    - group: root
    - mode:  644
    - output_loglevel: quiet
    - quiet: True

# Execute command to set SELinux to permissive mode (effectively disabling it)
disable-SELinux:
  cmd.run:
    - name: setenforce 0

# Execute command to set SELinux to permissive mode (effectively disabling it)
set-SELinux_config:
  cmd.run:
    - name: sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Ensure kubelet service is started and enabled
start-service_kubelet:
  service.running:
    - name: kubelet
    - enable: True
    - require:
      - pkg: kubelet

# Ensure firewalld service is stopped and disabled
stop-service_firewalld:
  service.dead:
    - name: firewalld
    - enable: False

# Execute command to disable swap
disable-swap:
  cmd.run:
    - name: swapoff -a

# Comment fstab swap configuration
comment-/etc/fstab:
  file.comment:
    - name:  /etc/fstab
    - regex: ^/dev/mapper/rl_