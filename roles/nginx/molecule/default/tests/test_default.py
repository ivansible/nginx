import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']
).get_hosts('all')


def test_nginx_service(host):
    ssh = host.service("nginx")
    assert ssh.is_running
    assert ssh.is_enabled


def test_http_port(host):
    sock = host.socket("tcp://127.0.0.1:80")
    assert sock.is_listening


def test_http_html(host):
    html = host.check_output("curl http://localhost")
    assert ('Welcome to nginx!' in html) or ('Site is suspended.' in html)


def test_https_port(host):
    sock = host.socket("tcp://127.0.0.1:443")
    assert sock.is_listening


def test_https_html(host):
    if os.environ.get('IVATEST_CHECK_HTTPS_HTML', 'true') == 'true':
        html = host.check_output("curl -k https://localhost")
        assert 'href="/favicon.ico"' in html
