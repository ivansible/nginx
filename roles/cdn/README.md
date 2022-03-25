# ivansible.srv_cdn

[![Github Test Status](https://github.com/ivansible/srv-cdn/workflows/test/badge.svg?branch=master)](https://github.com/ivansible/srv-cdn/actions)
[![Ansible Galaxy](https://img.shields.io/badge/galaxy-ivansible.srv__cdn-68a.svg?style=flat)](https://galaxy.ansible.com/ivansible/srv_cdn/)

This role configures simple nginx-based CDN.

Any CDN request can have few optional HTTP headers:
  - `X-CDN-Front` - desired front host name, defaults to host name from request.
  - `X-CDN-Host` - desired server host name, determines origin, defaults to `$cdn_front`.
  - `X-CDN-Back` - desired origin host name, optional, overrides origin.


## Requirements

None


## Variables

Available variables are listed below, along with default values.

```
    srv_cdn_sites:
      - server: .mydomain.com
        origin: www.example.com
        lecert: mydomain.com
```
The main list of sites has records with the following fields:
  - `server` - font server name, can be `full.host.name` or `.domain.name` (required);
  - `origin` - host name of an origin server, which must support https (required);
  - `lecert` - name of custom letsencrypt certificate for the server (optional);
  - `hidden` - if true, server-to-origin mapping is defined but server name is skipped
               (optional, defaults to `false`).

```
    srv_cdn_default_origin: example.com
```
The fallback origin.

```
    srv_cdn_cloudflare:
      - zone: example.com
        name: {{ inventory_hostname }}
        type: AAAA
        value: {{ ansible_default_ipv6.address }}
        proxied: false
```
The list of per-host cloudflare records has the following fields:
  - `zone` - zone for the record (required);
  - `name` - record name (usually unqualified hostname), required;
  - `type` - type of record, one of: A AAAA CNAME etc (required);
  - `value` - optional value, record will be skipped if this is empty or falsy;
  - `proxied` - true or false, defaults to `false`.

```
    srv_cdn_cloudflare_email: ~
    srv_cdn_cloudflare_token: ~
```
CloudFlare credentials. If these settings are empty, falsy or undefined,
then cloudflare tasks will be skipped.

```
    srv_cdn_cloudfront:
      - server: www.mydomain.com
        reference: www.mydomain.com_cdn1
        origin: override.example.com
        lecert: mydomain.com
        cache: false
```
This array configures CloudFront CDN distributions with full web paths
like `cloudfront -> server -> origin`, where each record has fields:
  - `server`    - front server name matching a record from the list of sites above
                  (required);
  - `origin`    - optional, overrides `origin` from the list of sites above;
  - `reference` - **unique** cloudfront identifier
                  (optional, defaults to the server name with a suffix);
  - `lecert`    - name of custom letsencrypt certificate for the server (optional);
  - `cache`     - `false` disables cloudfront caching, `true` - enables it
                  (optional, defaults to `srv_cdn_cloudfront_default_cache`);
  - `delete`    - if true, the distribution will be deleted instead of creating/updating
                  (optional, defaults to `false`).

```
    srv_cdn_cloudfront_default_reference: SERVER_cdn
```
Default name for distribution reference (`SERVER` is replaced by the actual server name).

```
    srv_cdn_filters:
      - src: ...
        dst: ...
```
These replacements will be applied to HTML.

    srv_cdn_cloudfront_max_ttl: 2592000    # one month
    srv_cdn_cloudfront_default_ttl: 86400  # one day
    srv_cdn_cloudfront_cached_methods: [GET, HEAD]
    srv_cdn_cloudfront_default_cache: true
Various defaults for CloudFront caching.

    srv_cdn_cloudfront_access_key: ~
    srv_cdn_cloudfront_secret_key: ~
Amazon CloudFront credentials, required if `srv_cdn_cloudfront` has records,
optional otherwise. If these settings are empty or undefined, they default to
the environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
on the ansible controller host.


## Tags

- `srv_cdn_cloudflare` - configures DNS records in CloudFlare
- `srv_cdn_cloudfront` - configures CloudFront distributions
- `srv_cdn_nginx` - configures CDN site and mappings in nginx
- `srv_cdn_nginx_site` - configures common CDN site settings in nginx
- `srv_cdn_all` - all of the above


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

Created in 2020-2021 by [IvanSible](https://github.com/ivansible)
