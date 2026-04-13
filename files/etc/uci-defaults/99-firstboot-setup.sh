#!/bin/sh
# 99-firstboot-setup.sh — runs once on first boot via uci-defaults

# Network: set LAN IP
if ! uci show network.lan > /dev/null 2>&1; then
  echo "⚠️ network.lan 不存在，跳过 IP 设置"
else
  uci set network.lan.ipaddr='192.168.2.1'
  uci commit network
fi

# System: hostname and timezone
uci set system.@system[0].hostname='OpenWrt'
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='Asia/Shanghai'
uci commit system

# FIX #12 & #14: Robust NTP setup.
# Check whether the 'ntp' timeserver section already exists;
# if not, create it with the correct section TYPE ('timeserver').
# Using `uci -q get` to test existence avoids the inverted-logic bug.
if ! uci -q get system.ntp > /dev/null 2>&1; then
  uci set system.ntp='timeserver'
fi
# Now it is safe to delete and re-add server list
uci -q delete system.ntp.server || true
uci add_list system.ntp.server='ntp.aliyun.com'
uci add_list system.ntp.server='ntp.tencent.com'
uci add_list system.ntp.server='cn.pool.ntp.org'
uci commit system

# FIX #13: Restart NTP daemon so new servers take effect immediately
# (uci-defaults runs before full init, so use a conditional reload)
if [ -x /etc/init.d/sysntpd ]; then
  /etc/init.d/sysntpd restart 2>/dev/null || true
fi

# DHCP: tune dnsmasq
uci set dhcp.@dnsmasq[0].cachesize='1000'
uci set dhcp.@dnsmasq[0].ednspacket_max='1232'
uci commit dhcp

exit 0
