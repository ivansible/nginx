# ivansible.lin_nginx

[![Github Test Status](https://github.com/ivansible/lin-nginx/workflows/test/badge.svg?branch=master)](https://github.com/ivansible/lin-nginx/actions)
[![Ansible Galaxy](https://img.shields.io/badge/galaxy-ivansible.lin__nginx-68a.svg?style=flat)](https://galaxy.ansible.com/ivansible/lin_nginx/)

This role installs `nginx` web server on linux machine


## Requirements

None


## Variables

### Variables from `ivansible.nginx_base` shared with other roles

    web_user: www-data
    web_group: www-data
Unix user and group for nginx service.

    web_domain: example.com
This is used to configure server name for default nginx site.

    web_ports: [80, 443]
These ports will be opened in the firewall.

    nginx_http_port: 80
    nginx_ssl_port: 443
These ports are used in configuration snippets.

    nginx_ssl_listen_addr: address, list of addresses, or '*' for all
IP addresses to listen for SSL traffic.
By default, all _public_ IPs amended by default IP addresses.

    nginx_conf_dir: /etc/nginx/conf.d
Extra configuration will be put here.

    nginx_site_dir: /etc/nginx/sites-enabled
The default nginx site configuration will be put here.

    nginx_stream_dir: /etc/nginx/streams.d
Stream module snippets will be put here.

    nginx_def_site_dir: /var/www/default
The default nginx site files will be put here.

    nginx_ssl_cert: <derived from letsencrypt setting>
    nginx_ssl_key: <derived from letsencrypt setting>
    nginx_letsencrypt_cert: ""
Setting one of these will activate HTTPS for default nginx site.


### Nginx role variables are listed below

    nginx_base_domain: "{{ web_domain }}"

    nginx_main_site: ""
If this setting is non-empty, accessing nginx at an unconfigured server name
will redirect to this URL.

    nginx_xframe_uri: nginx_main_site uri or 'same' or 'none'
This setting will trigger `SAMEORIGIN` frame security policy.

    nginx_cache_enable: true
This settings triggers creationg and configuration of nginx cache directories.

    nginx_local_resolver: false
If this is set to `true`, nginx will use to localhost dns resolver,
usually `dnsmasq`.

    nginx_behind_vpn: true
This setting affects how nginx reports its web port to upstream services
such as `uwsgi`.

    nginx_upload_progress: false
This setting activates the `upload_progress` nginx module.

    nginx_max_logs: ~
If set, this limits maximum number of rotated nginx logs by given number.

    nginx_cloudflare_ips: []
A list of IP subnets. Nginx will correctly expose its IP address when run
behind the cloudflare web proxy. See:
 - https://www.cloudflare.com/ips-v4
 - https://www.cloudflare.com/ips-v6
 - https://www.cloudflare.com/ips
 - https://www.babaei.net/blog/getting-real-ip-addresses-using-nginx-and-cloudflare
 - https://stackoverflow.com/q/26983893

```
    nginx_own_default_server: true
```
Set this to false if you provide your own default server.

    nginx_snimux_dir: /etc/nginx/snimux.d
    nginx_snimux_port: 3443
    nginx_nossl_upstream_port: 0
Optional settings to control nginx stream module multiplexing TLS ports.
The incoming TLS traffic will be normally accepted on `nginx_ssl_port`
(or `nginx_snimux_port` if nginx is running behind SSLH),
and multiplexed based on the config files below the `nginx_snimux_dir`
directory. Such files should be named like `facility.conf` and have the
contents like this: `sni.host.name [upstream_port]`.
The files can be added via task `ivansible.base.nginx/setup_sni_upstream.yml`.

All traffic that is not captured by listed host names will be redirected
to default port `nginx_ssl_port`, which is normally served by the Nginx
core http module.


## Tags

- `lin_nginx_install` -- install nginx package from nginx.org repository
- `lin_nginx_dirs` -- activate nginx cache and create directories under /etc/nginx
- `lin_nginx_config` -- create main configuration and uwsgi parameters
                        and add extra mime types
- `lin_nginx_tls` -- configure security settings
                     and generate diffie-helman parameters for tls
- `lin_nginx_site` -- configure default site and upload www files
- `lin_nginx_run` -- enable service and open ports in firewall
- `lin_nginx_logs` -- fine-tune nginx logs
- `lin_nginx_all` -- all of the above


## Dependencies

- [ivansible.lin_base](https://github.com/ivansible/lin-base)
  - common ansible handlers, default parameters and custom modules
  - global flag `lin_compress_logs`,
    which enables or disables compression of rotated logs
- [ivansible.nginx_base](https://github.com/ivansible/nginx-base)
  - common nginx-related handlers and default parameters


## Example Playbook

    - hosts: mysite
      roles:
         - role: ivansible.lin_nginx
           web_domain: mysite.com
           nginx_letsencrypt_cert: mysite.com
           nginx_main_site: www.mysite.com


## License

MIT

## Author Information

Created in 2018-2021 by [IvanSible](https://github.com/ivansible)
