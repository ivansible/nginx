# ivansible.lin_uwsgi

This role installs uwsgi on linux in the tyrant emperor mode.

The main service runs as root and spawns vassal processes for
each _ini_ configuration file found in the main vassal directory
`/etc/uwsgi-emperor/vassals` and optionally extra vassal directories
defined by the `uwsgi_vassal_dirs` setting.
Unix owner and group of vassal's _ini_ file define user and group of
the relevant vassal process and must allow to write a log in
the `/var/log/uwsgi` directory (usually setting the group to
`www-data` is enough).
The emperor daemon takes care of spawning and killing vassal
processes, rotating log files and so on.


## Requirements

None


## Variables

### Variables from `ivansible.nginx_base` shared with other roles

    uwsgi_base: /etc/uwsgi-emperor
    uwsgi_vassals: "{{ uwsgi_base }}/vassals"
    uwsgi_plugin_dir: /usr/lib/uwsgi/plugins


### Variables specific to `lin_uwsgi` role are listed below

    uwsgi_ini_file: "{{ uwsgi_base }}/emperor.ini"

    uwsgi_log_dir: /var/log/uwsgi
    uwsgi_user: "{{ web_user }}"
    uwsgi_group: "{{ web_group }}"
Note: by default, the uwsgi log directory is owned by
      the nginx process uid/gid.

    uwsgi_vassal_dirs: "{{ ansible_user_dir }}/etc/uwsgi"
Note: by default, uwsgi emperor looks for vassals in the given subdirectory
      of the target ansible user.

## Tags

- `lin_uwsgi_all`


## Dependencies

- [ivansible.lin_base](https://github.com/ivansible/lin-base)
  -- common ansible handlers and default parameters
- [ivansible.nginx_base](https://github.com/ivansible/nginx-base)
  -- common nginx-related handlers and default parameters


## Example Playbook

    - hosts: vagrant-boxes
      roles:
         - role: ivansible.lin_uwsgi


## License

MIT

## Author Information

Created in 2018-2020 by [IvanSible](https://github.com/ivansible)
