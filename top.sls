base:
  '*':
    - packages
  'roles:kubernetes_master':
    - match: grain
    - kubernetes
  'roles:kubernetes_worker':
    - match: grain
    - kubernetes