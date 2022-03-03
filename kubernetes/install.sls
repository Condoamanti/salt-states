# module: kubernetes: install
# state.apply kubernetes.install
#
# Pillar:
# /kubernetes/init.sls
#
# Description:
# Ensures kubernetes is installed

{% set kubernetes_server           = salt.pillar.get('kubernetes:nfs_storage:server') %}
{% set kubernetes_server_directory = salt.pillar.get('kubernetes:nfs_storage:server_directory') %}
{% set kubernetes_local_directory  = salt.pillar.get('kubernetes:nfs_storage:local_directory') %}
{% set kubernetes_options          = salt.pillar.get('kubernetes:nfs_storage:options') %}
{% set kubernetes_dump             = salt.pillar.get('kubernetes:nfs_storage:dump') %}
{% set kubernetes_fcsk             = salt.pillar.get('kubernetes:nfs_storage:fcsk') %}

include:
  - kubernetes.kubelet.init
  - kubernetes.kubeadm.init
  - kubernetes.kubectl.init
  - kubernetes.cri-o.init

create-/etc/yum.repos.d/kubernetes.repo:
  pkgrepo.managed:
    - name: kubernetes
    - baseurl: https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
    - enabled: 1
    - gpgkey: https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
    - gpgcheck: 1

# Execute command to set SELinux to permissive mode (effectively disabling it)
disable-SELinux:
  cmd.run:
    - name: setenforce 0

# Set SELinux mode to permissive mode (effectively disabling it)
set-SELinux_mode:
  selinux.mode:
    - name: permissive

# Ensure kubelet service is started and enabled
start-service_kubelet:
  service.running:
    - name: kubelet
    - enable: True
    - require:
      - pkg: kubelet

# Ensure firewalld service is running and started
start-service_firewalld:
  service.running:
    - name: firewalld
    - enable: True

# Create firewalld service .xml file for kubernetes
create-firewalld_service_kubernetes:
  firewalld.service:
    - name: kubernetes
    - ports:
{% for port in salt.pillar.get('kubernetes:firewalld:ports') %}
      - {{ port }}
{% endfor %}
    - require:
      - service: firewalld

# Apply kubernetes service to firewalld public
apply-firewalld_service_kubernetes_to_public:
  firewalld.present:
    - name: public
    - services:
      - kubernetes
    - watch:
      - firewalld: kubernetes

# Execute command to disable swap
disable-swap:
  cmd.run:
    - name: swapoff -a

# Comment fstab swap configuration
comment-/etc/fstab:
  file.comment:
    - name:  /etc/fstab
    - regex: ^\/dev\/mapper\/rl_.*-swap

# Install nfs-utils package
install-nfs-utils:
  pkg.installed:
    - name: nfs-utils

install-iproute-tc:
  pkg.installed:
    - name: iproute-tc

create-{{ kubernetes_local_directory }}:
  file.directory:
    - name: {{ kubernetes_local_directory }}
    - makedirs: True

# Update /etc/fstab configuration with nfs share
append-/etc/fstab:
  file.append:
    - name: /etc/fstab
    - text: "{{ kubernetes_server }}:{{ kubernetes_server_directory }} {{ kubernetes_local_directory }} nfs {{ kubernetes_options }} {{ kubernetes_dump }} {{ kubernetes_fcsk}}"
    - require:
      - pkg: nfs-utils
      - file: {{ kubernetes_local_directory }}

# Execute command to mount all from /etc/fstab
run-mount:
  cmd.run:
    - name: mount -a
    - watch:
      - file: /etc/fstab