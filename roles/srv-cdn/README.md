# ivansible.srv_mirror

[![Github Test Status](https://github.com/ivansible/srv-mirror/workflows/Molecule%20test/badge.svg?branch=master)](https://github.com/ivansible/srv-mirror/actions)
[![Travis Test Status](https://travis-ci.org/ivansible/srv-mirror.svg?branch=master)](https://travis-ci.org/ivansible/srv-mirror)
[![Ansible Galaxy](https://img.shields.io/badge/galaxy-ivansible.srv__mirror-68a.svg?style=flat)](https://galaxy.ansible.com/ivansible/srv_mirror/)

This role configures site mirroring in nginx.

A request can have two optional HTTP headers:
`X-Mirror-Front` - desired front host, and
`X-Mirror-Back` - desired origin host.


## Requirements

None


## Variables

Available variables are listed below, along with default values.

    srv_mirror_mirrors:
      - server: .mydomain.com
        origin: www.example.com
This is an array of records with the following fields:
`server` - font server name, can be `full.host.name` or `.domain.name`,
`origin` - host name of an origin server, which must support https.

    srv_mirror_default_origin: example.com
The fallback origin.

    srv_mirror_filters:
      - src: ...
        dst: ...
These replacements will be applied to HTML.


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
