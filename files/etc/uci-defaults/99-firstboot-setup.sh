#!/bin/sh
# 99-firstboot-setup.sh — 360 V6 终极初始化脚本

# ── 1. 软件源：切换至清华镜像 + 忽略签名 (解决 opkg 报错) ───────
DIST_ARCH=$(grep "DISTRIB_ARCH" /etc/openwrt_release | cut -d"'" -f2)
[ -z "$DIST_ARCH" ] && DIST_ARCH="aarch64_cortex-a53"

cat > /etc/opkg/distfeeds.conf <<EOF
src/gz openwrt_core https://mirrors.tuna.tsinghua.edu.cn/openwrt/snapshots/targets/qualcommax/ipq60xx/packages
src/gz openwrt_base https://mirrors.tuna.tsinghua.edu.cn/openwrt/snapshots/packages/$DIST_ARCH/base
src/gz openwrt_luci https://mirrors.tuna.tsinghua.edu.cn/openwrt/snapshots/packages/$DIST_ARCH/luci
src/gz openwrt_packages https://mirrors.tuna.tsinghua.edu.cn/openwrt/snapshots/packages/$DIST_ARCH/packages
src/gz openwrt_routing https://mirrors.tuna.tsinghua.edu.cn/openwrt/snapshots/packages/$DIST_ARCH/routing
EOF

# 允许未签名包，增强第三方插件兼容性
sed -i 's/option check_signature/# option check_signature/g' /etc/opkg.conf

# ── 2. 网络：设定 IP 为 192.168.2.1 ───────────────────────────
uci set network.lan.ipaddr='192.168.2.1'
uci commit network

# ── 3. 核心：持久化自动挂载脚本 (rc.local) ───────────────────────
# 确保每次重启都能自动挂载 U 盘并激活所有空间
cat > /etc/rc.local << 'EOF'
#!/bin/sh
# 延迟等待 USB 3.0 设备就绪
sleep 10

# 尝试挂载 U 盘
mount /dev/sda1 /mnt/usb

if [ -f /mnt/usb/swapfile ]; then
    # 1. 激活 U 盘 Swap (让 HomeProxy 和 Docker 有底气)
    swapon /mnt/usb/swapfile
    
    # 2. 迁移 Docker 数据目录 (使用 bind mount，不破坏原始结构)
    mkdir -p /mnt/usb/docker
    mkdir -p /opt/docker
    mount --bind /mnt/usb/docker /opt/docker
    
    # 3. 迁移 HomeProxy/sing-box 工作目录
    # 避免大量规则缓存挤占系统 512MB RAM
    mkdir -p /mnt/usb/homeproxy
    mkdir -p /etc/homeproxy
    mount --bind /mnt/usb/homeproxy /etc/homeproxy
    
    # 4. 迁移 AdGuardHome 数据库
    # AGH 的查询日志增长极快，必须放 U 盘
    mkdir -p /mnt/usb/AdGuardHome
    mkdir -p /etc/AdGuardHome
    mount --bind /mnt/usb/AdGuardHome /etc/AdGuardHome
fi

# 释放 CPU 性能模式
for cpu_gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    [ -f "$cpu_gov" ] && echo performance > "$cpu_gov"
done

exit 0
EOF
chmod +x /etc/rc.local

# ── 4. 其它细节优化 ───────────────────────────────────────────
# 禁用那个已经没用的 DNSFilter
/etc/init.d/dnsfilter disable 2>/dev/null

exit 0
