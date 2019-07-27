#!/bin/bash
set -euo pipefail
#set -x

. /etc/default/sslh
ACTION="${1:-}"
SSLH_UID=sslh
PROXY_GID=proxy
COMMENT=sslh_helper_ruleset
TAG="-m comment --comment ${COMMENT}"

set_capabilities()
{
  case ${1} in
    enable)
      CAPS="cap_net_bind_service,cap_net_admin+ep"
      /sbin/setcap ${CAPS} /usr/sbin/sslh-select
      /sbin/setcap ${CAPS} /usr/sbin/sslh
      ;;
    disable)
      /sbin/setcap "" /usr/sbin/sslh-select
      /sbin/setcap "" /usr/sbin/sslh
      ;;
    ignore)
      ;;
    *)
      echo "invalid value of TRANSPARENT_SETCAP"
      exit 1
      ;;
  esac
}

set_proxy_fix()
{
  /sbin/iptables -A OUTPUT -t nat ${TAG} \
    -m owner --gid-owner ${PROXY_GID} \
    -p tcp -m multiport --dports ${PROXY_PORTS} \
    -m addrtype --dst-type LOCAL ! -d 127.0.0.1/8 \
    -j DNAT --to-destination 127.0.0.1

  /sbin/ip6tables -A OUTPUT -t nat ${TAG} \
    -m owner --gid-owner ${PROXY_GID} \
    -p tcp -m multiport --dports ${PROXY_PORTS} \
    -m addrtype --dst-type LOCAL ! -d ::1 \
    -j DNAT --to-destination ::1
}

set_transparent()
{
  ### IPv4 ###

  # Drop martian packets as they would have been if route_localnet was zero
  # Packets not leaving the server aren't affected by this
  /sbin/iptables -t raw    -A PREROUTING  ! -i lo -d 127.0.0.0/8 -j DROP ${TAG}
  /sbin/iptables -t mangle -A POSTROUTING ! -o lo -s 127.0.0.0/8 -j DROP ${TAG}

  # Mark all connections made by sslh for special treatment
  /sbin/iptables -t nat -A OUTPUT ${TAG} \
    -p tcp --syn \
    -m owner --uid-owner ${SSLH_UID} \
    -j CONNMARK --set-xmark ${MARK_VALUE}/${MARK_MASK}

  # Mark (ctmark -> fwmark) outgoing packets destined to sslh for rerouting
  /sbin/iptables -t mangle -A OUTPUT ${TAG} \
    -p tcp ! -o lo \
    -m connmark --mark ${MARK_VALUE}/${MARK_MASK} \
    -j CONNMARK --restore-mark --mask ${MARK_MASK}

  # Configure routing for those marked packets
  /sbin/ip -4 rule add fwmark ${MARK_VALUE} lookup ${LOOKUP_TABLE}
  /sbin/ip -4 route add local 0/0 dev lo table 100

  ### IPv6 ###

  # Drop martian packets as they would have been if route_localnet was zero
  # Packets not leaving the server aren't affected by this
  /sbin/ip6tables -t raw    -A PREROUTING  ! -i lo -d ::1/128 -j DROP ${TAG}
  /sbin/ip6tables -t mangle -A POSTROUTING ! -o lo -s ::1/128 -j DROP ${TAG}

  # Mark all connections made by sslh for special treatment
  /sbin/ip6tables -t nat -A OUTPUT ${TAG} \
    -m owner --uid-owner ${SSLH_UID} \
    -p tcp --syn \
    -j CONNMARK --set-xmark ${MARK_VALUE}/${MARK_MASK}

  # Mark (ctmark -> fwmark) outgoing packets destined to sslh for rerouting
  /sbin/ip6tables -t mangle -A OUTPUT ${TAG} \
    -p tcp ! -o lo \
    -m connmark --mark ${MARK_VALUE}/${MARK_MASK} \
    -j CONNMARK --restore-mark --mask ${MARK_MASK}

  # Configure routing for those marked packets
  /sbin/ip -6 rule  add fwmark ${MARK_VALUE} lookup ${LOOKUP_TABLE}
  /sbin/ip -6 route add local  ::/0  dev lo table ${LOOKUP_TABLE}
}

start()
{
  if [ ${USE_PROXY_FIX} = true ]; then
    set_proxy_fix
  fi

  if [ ${USE_TRANSPARENT} = true ]; then
    # Allow sslh to use localhost as destination
    /sbin/sysctl -q -w net.ipv4.conf.default.route_localnet=1
    /sbin/sysctl -q -w net.ipv4.conf.all.route_localnet=1

    # sslh requires net admin capabilities for transparent redirect
    set_capabilities ${TRANSPARENT_SETCAP:-ignore}

    set_transparent
  fi
}

stop()
{
  if [ ${USE_PROXY_FIX} = true -o ${USE_TRANSPARENT} = true ]; then
    /sbin/iptables-save  | /bin/grep -v ${COMMENT} | /sbin/iptables-restore
    /sbin/ip6tables-save | /bin/grep -v ${COMMENT} | /sbin/ip6tables-restore
  fi

  if [ ${USE_TRANSPARENT} = true ]; then
    /sbin/ip -4 rule  del fwmark ${MARK_VALUE} lookup ${LOOKUP_TABLE} 2>/dev/null || true
    /sbin/ip -6 rule  del fwmark ${MARK_VALUE} lookup ${LOOKUP_TABLE} 2>/dev/null || true
    /sbin/ip -4 route del local  0/0  dev lo table ${LOOKUP_TABLE} 2>/dev/null || true
    /sbin/ip -6 route del local  ::/0 dev lo table ${LOOKUP_TABLE} 2>/dev/null ||true
  fi
}

case "${ACTION}" in
  start) start ;;
  stop)  stop ;;
  restart|reload) stop; start ;;
  *) echo "usage: $0 start|stop|restart"; exit 1 ;;
esac
