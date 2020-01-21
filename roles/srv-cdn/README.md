# ivansible.srv_mirror

[![Github Test Status](https://github.com/ivansible/srv-mirror/workflows/Molecule%20test/badge.svg?branch=master)](https://github.com/ivansible/srv-mirror/actions)
[![Travis Test Status](https://travis-ci.org/ivansible/srv-mirror.svg?branch=master)](https://travis-ci.org/ivansible/srv-mirror)
[![Ansible Galaxy](https://img.shields.io/badge/galaxy-ivansible.srv__mirror-68a.svg?style=flat)](https://galaxy.ansible.com/ivansible/srv_mirror/)

This role configures site mirroring in nginx.


## Requirements

None


## Variables

Available variables are listed below, along with default values.

    srv_mirror_mirrors:
      - server: default
        origin: www.example.com
`srv_mirror_mirrors` is an array of records with the following fields:

    server
Front server name, which can be `default` (must go first)
or `full.host.name` or `.domain.name`.

    origin
Host name of an origin server, which must support https.


## Tags

- `srv_mirror_all`


## Dependencies

- `ivansible.nginx_base` - inherit defaults and handlers
- `ivansible.lin_nginx`  (implicit dependency)


## Example Playbook

    - hosts: myserver
      roles:
         - role: ivansible.srv_cdn


## License

MIT


## Author Information

Created in 2020 by [IvanSible](https://github.com/ivansible)
