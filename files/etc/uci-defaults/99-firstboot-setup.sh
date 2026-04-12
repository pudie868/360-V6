#!/bin/sh
uci show network.lan > /dev/null 2>&1 || { echo "⚠️ network.lan 不存在，跳过 IP 设置"; exit 0; }
uci set network.lan.ipaddr='192.168.2.1'
uci commit network
uci set system.@system[0].hostname='OpenWrt'
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='Asia/Shanghai'
uci commit system
uci show system.ntp > /dev/null 2>&1 || uci set system.ntp='timeserver'
uci -q delete system.ntp.server
uci add_list system.ntp.server='ntp.aliyun.com'
uci add_list system.ntp.server='ntp.tencent.com'
uci add_list system.ntp.server='cn.pool.ntp.org'
uci commit system
uci set dhcp.@dnsmasq[0].cachesize='1000'
uci set dhcp.@dnsmasq[0].ednspacket_max='1232'
uci commit dhcp
exit 0
