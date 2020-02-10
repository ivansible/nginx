# Simple CDN (named server)
# ansible-managed

{{ nginx_conf_listen_http }}
{% if nginx_ssl_cert %}
{{ nginx_conf_listen_ssl }}
{% endif %}
# ssl_early_data on;  # nginx 1.15.4+, needs tls 1.3, possible replay attacks

location /  {
    # Accept either direct connections (blank forwarded proto) or SSL behind CloudFlare
    if ( $http_x_forwarded_proto !~ "^(https)?$" ) { return 301 "https://$host$uri"; }
    # Uncomment next line after enabling SSL in CloudFlare
    if ( $https != "on" ) { return 301 "https://$host$uri"; }

    proxy_pass https://$cdn_back;
    proxy_ssl_server_name on;
    proxy_redirect "~*^https?://[^/]+/(.*)$" "https://$cdn_front/$1";
    proxy_set_header Host $cdn_back;
    proxy_set_header Referer https://$cdn_back;

    proxy_set_header Accept-Encoding "";

{% for filter in srv_cdn_filters %}
    sub_filter '{{ filter.src }}'  '{{ filter.dst }}';
{% endfor %}
    sub_filter_once off;
    sub_filter_last_modified on;

    root {{ nginx_def_site_dir }};
}

include mixin.d/*.conf;
