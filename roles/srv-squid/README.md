# ivansible.srv_squid

This role installs `squid` with ssl support on linux:
 - install custom package with ssl support from the [llxdev ppa](https://launchpad.net/~llxdev/+archive/ubuntu/xenial/);
 - configure incoming port for unencrypted http access;
 - configure port and ssl certificate for incoming ssl access;
   currently, self-signed certificate is installed,
   but _letsencrypt_ integration is planned;
 - configure authentication, by default using _MD5_ passwords
   in a _http.passwd_ file, or optionally _LDAP_-based;
 - configure upstream peers based on acl rules
   e.g. to redirect `.onion` request to a local _tor daemon_;
 - optionally setup conditional outgoing _IP addresses_,
   e.g. for integration such upstream services as _cjdns_;
 - optionaly setup _URL rewriting_;
 - setup adblock rules;
 - tune cache for performance;


## Requirements

None


## Variables

Available variables are listed below, along with default values.

    squid_domain: none
By default, `squid_domain` is derived from the fully qualified host name.
This setting is used in many places in the squid conifguration file, e.g.:
`visible_hostname`, `ftp_user` e-mail, `cache_mgr` e-mail
and for ldap authentication.

    squid_ssl_enable: false
If this flag is truthy, the script will install SSL certificate, configure SSL port in squid and open it in the firewall.

    squid_allow_unencrypted: true
If this flag is truthy, the non-ssl ports will be open in the firewall.

    squid_port: 3128
    squid_ssl_port: 3129
Unencrypted and SSL-enabled incoming ports

    squid_host: "{{ ansible_fqdn }}"
Used as common name in self-signed ssl certificate.

    squid_pkg: squid-ssl
If this is `squid`, a package from universe will be installed.
If this is `squid-ssl`, a custom SSL-enabled package from `llxdev` ppa will be installed. Please note that this PPA does not yet provide packages for _bionic_. As a workaround, _xenial_ packages are installed in that case.

    squid_user: proxy
    squid_group: proxy
Daemon will run as this Unix user/group.

    squid_auth_ldap: false

    squid_auth_htpasswd: false
    squid_proxy_users: []
Example list entry:

      - user: username1
        pass: password1

    squid_use_squidguard: false

    squid_cachemgr_password: secretpass

    squid_local_subnets: []
      - 192.168.0.0/16

    squid_nopassword_networks: []
Example list entry:

      - name: internal
        ranges:
         - "192.168.0.0/16"

    squid_url_rewrite: []
Example list entry:

      - src: "http://orig-site.com"
        dst: "http://final-site.com"

    squid_domain_rules: []
Example list entry:

      - name: rulename
        domain: onion
        host: tor-proxy.local
        localhost: true
        port: 8118
If `localhost` is `true` then the host will be added to `/etc/hosts`

    squid_outgoing_addresses: []

Example list entry:
      - name: destination_name
        network: "192.168.0.0/16"
        via: "10.11.0.1"

    squid_pac_types:
      - name: http
        url: "PROXY {{ squid_host }}:{{ squid_port }}"
      - name: ssl
        url: "HTTPS {{ squid_host }}:{{ squid_ssl_port }}"


## Rule files

- Adblock:
  - dstdomain.deny
  - dstdom_regex.deny
  - url_regex.deny


## Tags

- `srv_squid_install` -- install squid package
- `srv_squid_ssl` -- setup ssl certificates
- `srv_squid_config` -- configure squid
- `srv_squid_firewall` -- open squid ports
- `srv_squid_iptables` -- ensure that some iptables rules exist
- `srv_squid_service` -- activate squid service
- `srv_squid_pac` -- generate example pac files
- `srv_squid_logs` -- fine-tune squid logs
- `srv_squid_all` -- all of the above


## Dependencies

- [ivansible.lin_base](https://github.com/ivansible/lin-base)
  - common ansible handlers, default parameters and custom modules
  - global flag `lin_compress_logs`,
    which enables or disables compression of rotated logs
- [ivansible.lin_tor](https://github.com/ivansible/lin-tor)


## Example Playbook

    - hosts: example
      roles:
         - role: ivansible.srv_squid
           squid_host: example.domain.com
           squid_ssl_enable: true
           squid_ssl_port: 443


## License

MIT

## Author Information

Created in 2018-2020 by [IvanSible](https://github.com/ivansible)
