# module: kubernetes.cri-o: install
# state.apply kubernetes.cri-o.install
#
# Description:
# Ensures cri-o is installed

# Create .conf file for cri-o to load modules at bootup
create-/etc/modules-load.d/crio.conf:
  file.managed:
    - name:  /etc/modules-load.d/crio.conf
    - source: salt://files/linux/rhel/etc/modules-load.d/crio.conf
    - user:  root
    - group: root
    - mode:  644
    - output_loglevel: quiet
    - quiet: True

run-modprobe_overlay:
  cmd.run:
    - name: modprobe overlay
    - onchanges:
      - file: /etc/modules-load.d/crio.conf

run-modprobe_br_netfilter:
  cmd.run:
    - name: modprobe br_netfilter
    - onchanges:
      - file: /etc/modules-load.d/crio.conf

# Create .conf file for sysctl params, these persist across reboots
create-/etc/sysctl.d/99-kubernetes-cri.conf:
  file.managed:
    - name:  /etc/sysctl.d/99-kubernetes-cri.conf
    - source: salt://files/linux/rhel/etc/sysctl.d/99-kubernetes-cri.conf
    - user:  root
    - group: root
    - mode:  644
    - output_loglevel: quiet
    - quiet: True

run-sysctl:
  cmd.run:
    - name: sysctl --system
    - onchanges:
      - file: /etc/sysctl.d/99-kubernetes-cri.conf

# Create repository file for devel-kubic-libcontainers-stable
create-/etc/yum.repos.d/devel-kubic-libcontainers-stable.repo:
  file.managed:
    - name:  /etc/yum.repos.d/devel-kubic-libcontainers-stable.repo
    - source: salt://files/linux/rhel/etc/yum.repos.d/devel-kubic-libcontainers-stable.repo
    - user:  root
    - group: root
    - mode:  644
    - output_loglevel: quiet
    - quiet: True

# Create repository file for devel-kubic-libcontainers-stable-cri-o-1.20
create-/etc/yum.repos.d/devel-kubic-libcontainers-stable-cri-o-1.20.repo:
  file.managed:
    - name:  /etc/yum.repos.d/devel-kubic-libcontainers-stable-cri-o-1.20.repo
    - source: salt://files/linux/rhel/etc/yum.repos.d/devel-kubic-libcontainers-stable-cri-o-1.20.repo
    - user:  root
    - group: root
    - mode:  644
    - output_loglevel: quiet
    - quiet: True

# Install cri-o package
install-cri-o:
  pkg.installed:
    - name: cri-o
    #- version: 1.20
    - require:
      - file: /etc/yum.repos.d/devel-kubic-libcontainers-stable.repo
      - file: /etc/yum.repos.d/devel-kubic-libcontainers-stable-cri-o-1.20.repo

# Ensure cri-o service is started and enabled
start-service_cri-o:
  service.running:
    - name: cri-o
    - enable: True
    - require:
      - pkg: cri-o