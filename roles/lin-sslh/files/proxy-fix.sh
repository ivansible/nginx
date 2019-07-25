#!/bin/bash
set -euo pipefail
#set -x

. /etc/default/sslh
COMMENT="sslh_rule_proxy_fix"
TAG="-m comment --comment ${COMMENT}"

start()
{
  /sbin/iptables -A OUTPUT -t nat ${TAG} \
    -m owner --gid-owner proxy \
    -p tcp -m multiport --dports ${PROXY_PORTS} \
    -m addrtype --dst-type LOCAL ! -d 127.0.0.1/8 \
    -j DNAT --to-destination 127.0.0.1

  /sbin/ip6tables -A OUTPUT -t nat ${TAG} \
    -m owner --gid-owner proxy \
    -p tcp -m multiport --dports ${PROXY_PORTS} \
    -m addrtype --dst-type LOCAL ! -d ::1 \
    -j DNAT --to-destination ::1
}

stop()
{
  /sbin/iptables-save  | /bin/grep -v ${COMMENT} | /sbin/iptables-restore
  /sbin/ip6tables-save | /bin/grep -v ${COMMENT} | /sbin/ip6tables-restore
}

case "${1:-}" in
  start) start ;;
  stop)  stop ;;
  restart|reload) stop; start ;;
  *) echo "usage: $0 start|stop|restart"; exit 1 ;;
esac
