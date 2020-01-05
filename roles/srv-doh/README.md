# ivansible.srv_doh

This role installs [rust-doh](https://github.com/jedisct1/rust-doh),
fast and secure DNS-over-HTTP server proxy, and configures nginx fronting.


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
- `ivansible.srv_ss`


## Example Playbook

    - hosts: server
      roles:
         - role: ivansible.srv_doh
           variable1: 1
           variable2: 2


## License

MIT

## Author Information

Created in 2019-2020 by [IvanSible](https://github.com/ivansible)
