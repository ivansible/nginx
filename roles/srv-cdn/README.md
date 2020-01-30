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

```
    srv_mirror_mirrors:
      - server: .mydomain.com
        origin: www.example.com
```
This is an array of records with the following fields:
  - `server` - font server name, can be `full.host.name` or `.domain.name` (required);
  - `origin` - host name of an origin server, which must support https (required);
  - `hidden` - if true, server-to-origin mapping is defined but server name is skipped
               (optional, defaults to `false`).

```
    srv_mirror_default_origin: example.com
```
The fallback origin.

```
    srv_mirror_cloudfront:
      - server: www.mydomain.com
        reference: cdn1_www.mydomain.com
        origin: override.example.com
        cache: false
```
This array configures CloudFront CDN distributions with full web paths
like `cloudfront -> server -> origin`, where each record has fields:
  - `server`    - front server name matching a record from the list of mirrors above
                  (required);
  - `origin`    - optional, overrides `origin` from the list of mirrors above;
  - `reference` - **unique** cloudfront identifier
                  (optional, defaults to the server name with a suffix);
  - `cache`     - `false` disables cloudfront caching, `true` - enables it
                  (optional, defaults to `srv_mirror_cloudfront_default_cache`);
  - `delete`    - if true, the distribution will be deleted instead of creating/updating
                  (optional, defaults to `false`).

```
    srv_mirror_cloudfront_default_reference: SERVER_ansible-mirror
```
Default name for distribution reference (`SERVER` is replaced by the actual server name).

```
    srv_mirror_filters:
      - src: ...
        dst: ...
```
These replacements will be applied to HTML.
Note that `$mirror_front` in the destination string is an alias for `$http_host`.

    srv_mirror_cloudfront_max_ttl: 2592000    # one month
    srv_mirror_cloudfront_default_ttl: 86400  # one day
    srv_mirror_cloudfront_cached_methods: [GET, HEAD]
    srv_mirror_cloudfront_default_cache: true
Various defaults for CloudFront caching.

    srv_mirror_cloudfront_access_key: ""
    srv_mirror_cloudfront_secret_key: ""
Amazon CloudFront credentials, required if `srv_mirror_cloudfront` has records,
optional otherwise. If these settings are empty or undefined, they default to
the environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
on the ansible controller host.


## Tags

- `srv_mirror_cloudfront` - configures cloudfront distributions
- `srv_mirror_nginx` - configures site mirroring in nginx
- `srv_mirror_all` - all of the above


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
