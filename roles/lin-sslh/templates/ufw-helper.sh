#!/bin/bash
set -euo pipefail
#set -x

#. /etc/default/sslh
case "${USE_TRANSPARENT:-}" in
  true)  ;;
  false) exit 0 ;;
  *) echo "$0 must be run by systemd"; exit 1 ;;
esac

rules()
{
  case "$1" in
    start)
      OPT="-A"
      CMD="add"
      LOG=""
      SYSCTL=true
      ;;
    stop)
      OPT="-D"
      CMD="del"
      LOG="2>/dev/null || true"  # this hack requires eval
      SYSCTL=false
      ;;
  esac

  if [ ${SYSCTL} = true ]; then
    # Allow sslh to use localhost as destination
    /sbin/sysctl -q -w net.ipv4.conf.default.route_localnet=1
    /sbin/sysctl -q -w net.ipv4.conf.all.route_localnet=1
  fi

  TAG="-m comment --comment ${RULE_COMMENT}"

  # This script requires root or capabilities: CAP_NET_ADMIN CAP_NET_RAW

  ### IPv4 ###

  # Drop martian packets as they would have been if route_localnet was zero
  # Packets not leaving the server aren't affected by this
  eval /sbin/iptables -t raw ${OPT} PREROUTING ${TAG} \
                      ! -i lo -d 127.0.0.0/8 -j DROP ${LOG}
  eval /sbin/iptables -t mangle ${OPT} POSTROUTING ${TAG} \
                      ! -o lo -s 127.0.0.0/8 -j DROP ${LOG}

  # Mark all connections made by sslh for special treatment
  eval /sbin/iptables -t nat ${OPT} OUTPUT ${TAG} \
                      -p tcp --syn \
                      -m owner --uid-owner ${SSLH_UID} \
                      -j CONNMARK --set-xmark ${MARK_VALUE}/${MARK_MASK} ${LOG}

  # Mark (ctmark -> fwmark) outgoing packets destined to sslh for rerouting
  eval /sbin/iptables -t mangle ${OPT} OUTPUT ${TAG} \
                      -p tcp ! -o lo \
                      -m connmark --mark ${MARK_VALUE}/${MARK_MASK} \
                      -j CONNMARK --restore-mark --mask ${MARK_MASK} ${LOG}

  # Set routing for marked IPv4 packets
  eval /sbin/ip -4 rule  ${CMD} fwmark ${MARK_VALUE} lookup ${ROUTE_TABLE} ${LOG}
  eval /sbin/ip -4 route ${CMD} local  0/0  dev lo   table  ${ROUTE_TABLE} ${LOG}

  ### IPv6 ###

  # Drop martian packets as they would have been if route_localnet was zero
  # Packets not leaving the server aren't affected by this
  eval /sbin/ip6tables -t raw ${OPT} PREROUTING ${TAG} \
                       ! -i lo -d ::1/128 -j DROP ${LOG}
  eval /sbin/ip6tables -t mangle ${OPT} POSTROUTING ${TAG} \
                       ! -o lo -s ::1/128 -j DROP ${TAG} ${LOG}

  # Mark all connections made by sslh for special treatment
  eval /sbin/ip6tables -t nat ${OPT} OUTPUT ${TAG} \
                       -m owner --uid-owner ${SSLH_UID} \
                       -p tcp --syn \
                       -j CONNMARK --set-xmark ${MARK_VALUE}/${MARK_MASK} ${LOG}

  # Mark (ctmark -> fwmark) outgoing packets destined to sslh for rerouting
  eval /sbin/ip6tables -t mangle ${OPT} OUTPUT ${TAG} \
                       -p tcp ! -o lo \
                       -m connmark --mark ${MARK_VALUE}/${MARK_MASK} \
                       -j CONNMARK --restore-mark --mask ${MARK_MASK} ${LOG}

  # Set routing for marked IPv6 packets
  eval /sbin/ip -6 rule  ${CMD} fwmark ${MARK_VALUE} lookup ${ROUTE_TABLE} ${LOG}
  eval /sbin/ip -6 route ${CMD} local  ::/0  dev lo  table  ${ROUTE_TABLE} ${LOG}
}

case "${1:-}" in
  start) rules start ;;
  stop)  rules stop  ;;
  restart|reload) rules stop; rules start ;;
  *) echo "usage: $0 start|stop|restart"; exit 1 ;;
esac
