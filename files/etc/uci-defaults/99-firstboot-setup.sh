#!/bin/sh
# OpenWrt 首次启动执行（执行后自动删除）

# 1. 验证 lan 接口存在
uci show network.lan > /dev/null 2>&1 || {
  echo "⚠️ network.lan 不存在，跳过 IP 设置"
  exit 0
}

# 2. 设置 LAN IP
uci set network.lan.ipaddr='192.168.2.1'
uci commit network

# 3. 时区与主机名
uci set system.@system[0].hostname='OpenWrt'
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='Asia/Shanghai'
uci commit system

# 4. NTP 服务器（国内优先）- 确保节存在 + 可靠清空重建
uci show system.ntp > /dev/null 2>&1 || uci set system.ntp='timeserver'
uci -q delete system.ntp.server
uci add_list system.ntp.server='ntp.aliyun.com'
uci add_list system.ntp.server='ntp.tencent.com'
uci add_list system.ntp.server='cn.pool.ntp.org'
uci commit system

# 5. DNS 缓存优化
uci set dhcp.@dnsmasq[0].cachesize='1000'
uci set dhcp.@dnsmasq[0].ednspacket_max='1232'
uci commit dhcp

exit 0
