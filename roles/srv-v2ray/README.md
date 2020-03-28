# ivansible.srv_v2ray

[![Github Test Status](https://github.com/ivansible/srv-v2ray/workflows/Molecule%20test/badge.svg?branch=master)](https://github.com/ivansible/srv-v2ray/actions)
[![Travis Test Status](https://travis-ci.org/ivansible/srv-v2ray.svg?branch=master)](https://travis-ci.org/ivansible/srv-v2ray)
[![Ansible Galaxy](https://img.shields.io/badge/galaxy-ivansible.srv__v2ray-68a.svg?style=flat)](https://galaxy.ansible.com/ivansible/srv_v2ray/)

This role deploys [v2ray](https://github.com/v2ray/v2ray-core/) server on Linux.


## Requirements

None


## Variables

Available variables are listed below, along with default values.

    srv_v2ray_port: 65001
    srv_v2ray_direct: false
Port where v2ray listens for incoming websocket connections.
If `direct` is true, the port will be open for all.
If false, the port will be blocked from external networks.
By default port is blocked and _nginx_ is configured as redirector.

    srv_v2ray_web_path: /v2ray
Accepted HTTP path.

    srv_v2ray_uuid: aaa-111-222-333-4444
    srv_v2ray_altids: 4
    srv_v2ray_security: aes-128-gcm
Encryption parameters. `uuid` is a client user id in the form of _UUID_.
`altids` gives the number of deterministic alternative IDs in the range
between 0 and 65535 (4 recommended). The `security` method is one of:
`aes-128-gcm` or `chacha20-poly1305`.

    srv_v2ray_upgrade: false
Enables upgrading v2ray binaries (by default not upgraded if already installed).


## Tags

- `srv_v2ray_install` -- install v2ray-core files
- `srv_v2ray_config` -- update configuration
- `srv_v2ray_nginx` -- configure nginx redirector
- `srv_v2ray_service` -- activate systemd service
- `srv_v2ray_firewall` -- open (or block) v2ray port in firewall


## Dependencies

- `ivansible.srv_cdn` -- configures common nginx redirector
                         for all websocket based services.


## Example Playbook

    - hosts: myserver
      roles:
         - role: ivansible.srv_v2ray
           srv_v2ray_web_path: /sub-path/v2ray/
           srv_v2ray_uuid: 80cd4553-1071-4e5b-8d42-2564c32ab985
           srv_v2ray_security: chacha20-poly1305


## License

MIT


## Author Information

Created in 2020 by [IvanSible](https://github.com/ivansible)
