# module: kubernetes.cri-o: install
# state.apply kubernetes.cri-o.install
#
# Pillar:
# /kubernetes/init.sls
#
# Description:
# Ensures cri-o is installed

{% set crio_version = salt.pillar.get('kubernetes:crio:version').split('.') %}

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

create-/etc/yum.repos.d/devel-kubic-libcontainers-stable.repo:
  pkgrepo.managed:
    - comments: 
      - 'Stable Releases of Upstream github.com/containers packages (CentOS_8)'
    - name: devel_kubic_libcontainers_stable
    - baseurl: https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/CentOS_8/
    - enabled: 1
    - gpgkey: https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/CentOS_8/repodata/repomd.xml.key
    - gpgcheck: 1

create-/etc/yum.repos.d/devel-kubic-libcontainers-stable-cri-o-{{ crio_version[0] }}.{{ crio_version[1] }}.repo:
  pkgrepo.managed:
    - comments: 
      - 'devel:kubic:libcontainers:stable:cri-o:{{ crio_version[0] }}.{{ crio_version[1] }} (CentOS_8)'
    - name: devel_kubic_libcontainers_stable_cri-o_{{ crio_version[0] }}.{{ crio_version[1] }}
    - baseurl: https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/{{ crio_version[0] }}.{{ crio_version[1] }}/CentOS_8/
    - enabled: 1
    - gpgkey: https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/{{ crio_version[0] }}.{{ crio_version[1] }}/CentOS_8/repodata/repomd.xml.key
    - gpgcheck: 1

# Install cri-o package
install-cri-o_{{ crio_version[0] }}.{{ crio_version[1] }}.{{ crio_version[2] }}:
  pkg.installed:
    - name: cri-o
    - version: "{{ crio_version[0] }}.{{ crio_version[1] }}.{{ crio_version[2] }}"
    - require:
      - pkgrepo: devel_kubic_libcontainers_stable
      - pkgrepo: devel_kubic_libcontainers_stable_cri-o_{{ crio_version[0] }}.{{ crio_version[1] }}

# Ensure crio service is started and enabled
start-service_crio:
  service.running:
    - name: crio
    - enable: True
    - require:
      - pkg: cri-o