# Create samba credential file
create-/root/.smbcredentials:
  file.managed:
    - name:  /root/.smbcredentials
    - source: salt://files/linux/rhel/root/.smbcredentials
    - user:  root
    - group: root
    - mode:  644
    - output_loglevel: quiet
    - quiet: True

# Install cifs-utils package
install-cifs-utils:
  pkg.installed:
    - name: cifs-utils
    - require:
      - file: /root/.smbcredentials

# Create /mnt/cifs directory
create-/mnt/cifs:
  file.directory:
    - name:  /mnt/cifs
    - user:  root
    - group: root
    - mode:  755

# Create /mnt/cifs/movies directory
create-/mnt/cifs/movies:
  file.directory:
  - name:  /mnt/cifs/movies
  - user:  root
  - group: root
  - mode:  755
  - require:
    - file: /mnt/cifs

# Append to file /etc/fstab the connection information for backend storage
append-/etc/fstab:
  file.append:
    - name: /etc/fstab
    - text:
      - "//192.168.240.245/movies /mnt/cifs/movies cifs uid=0,credentials=/root/.smbcredentials,iocharset=utf8,file_mode=0644,dir_mode=0755 0 0"
      - "//192.168.240.245/tv_shows /mnt/cifs/tv_shows cifs uid=0,credentials=/root/.smbcredentials,iocharset=utf8,file_mode=0644,dir_mode=0755 0 0"
    - require:
      - file: /root/.smbcredentials
      - file: /mnt/cifs/tv_shows
      - file: /mnt/cifs/movies
      - pkg:  cifs-utils

# Execute command to enable mounts to be active and available
run-command_mount:
  cmd.run:
    - name: mount -a
    - require:
      - file: /etc/fstab
    - onchanges:
        - file: /etc/fstab

# Create /mnt/cifs/tv_shows directory
create-/mnt/cifs/tv_shows:
 file.directory:
  - name:  /mnt/cifs/tv_shows
  - user:  root
  - group: root
  - mode:  755
  - require:
    - file: /mnt/cifs

# Add /etc/yum.repos.d/plexmediaserver.repo repository file
add-pkgrepo_plexmediaserver:
  pkgrepo.managed:
    - name: plexmediaserver
    - humanname: plexmediaserver
    - enabled: true
    - baseurl: https://downloads.plex.tv/repo/rpm/$basearch/
    - gpgkey: https://downloads.plex.tv/plex-keys/PlexSign.key
    - gpgcheck: 1

# Install plexmediaserver package
install-package_plexmediaserver:
  pkg.installed:
    - name: plexmediaserver
    - require:
      #- file: /etc/yum.repos.d/plex.repo
      - pkgrepo: plexmediaserver

start-service_plexmediaserver:
  service.running:
    - name: plexmediaserver
    - enable: True

create-firewalld_service_plexmediaserver:
  firewalld.service:
    - name: plexmediaserver
    - ports:
      - 32400/tcp
      - 32469/tcp
      - 8324/tcp
      - 3005/tcp
      - 32414/udp
      - 32413/udp
      - 32412/udp
      - 32410/udp
      - 1900/udp
      - 5353/udp
    - require:
      - service: plexmediaserver

add-firewalld_service_plexmediaserver:
  firewalld.present:
    - name: public
    - services:
      - plexmediaserver
    - require:
      - firewalld: plexmediaserver