# ivansible.srv_doh

This role performs:
 - action1;
 - action2;


## Requirements

None


## Variables

Available variables are listed below, along with default values.

    variable1: 1
    variable2: 2


## Tags

- `srv_doh_all`


## Dependencies

- `ivansible.lin_nginx`
- `ivansible.lin_shadowsocks`


## Example Playbook

    - hosts: vagrant-boxes
      roles:
         - role: ivansible.srv_doh
           variable1: 1
           variable2: 2


## License

MIT

## Author Information

Created in 2019 by [IvanSible](https://github.com/ivansible)
