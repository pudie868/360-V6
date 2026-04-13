#!/bin/sh
# 99-firstboot-setup.sh — runs once on first boot via uci-defaults

# Network: set LAN IP
# 不做存在性检查，直接设置。
# uci-defaults 在 /etc/config/network 已由 base-files 生成后运行，
# network.lan 一定存在；即使不存在，uci set 会自动创建。
uci set network.lan.ipaddr='192.168.2.1'
uci set network.lan.netmask='255.255.255.0'
uci commit network

# System: hostname and timezone
uci set system.@system[0].hostname='OpenWrt'
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='Asia/Shanghai'
uci commit system

# NTP
if ! uci -q get system.ntp > /dev/null 2>&1; then
  uci set system.ntp='timeserver'
fi
uci -q delete system.ntp.server || true
uci add_list system.ntp.server='ntp.aliyun.com'
uci add_list system.ntp.server='ntp.tencent.com'
uci add_list system.ntp.server='cn.pool.ntp.org'
uci commit system

if [ -x /etc/init.d/sysntpd ]; then
  /etc/init.d/sysntpd restart 2>/dev/null || true
fi

# DHCP: tune dnsmasq
uci set dhcp.@dnsmasq[0].cachesize='1000'
uci set dhcp.@dnsmasq[0].ednspacket_max='1232'
uci commit dhcp

exit 0
