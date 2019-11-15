# ivansible.srv_chisel

This role installs [chisel](https://github.com/jpillora/chisel) server on linux.


## Requirements

None


## Variables

Available variables are listed below, along with default values.

    variable1: 1
    variable2: 2


## Tags

- `srv_chisel_all`


## Dependencies

- `ivansible.lin_nginx`
- `ivansible.lin_shadowsocks`


## Example Playbook

    - hosts: vagrant-boxes
      roles:
         - role: ivansible.srv_chisel
           variable1: 1
           variable2: 2


## License

MIT

## Author Information

Created in 2019 by [IvanSible](https://github.com/ivansible)
