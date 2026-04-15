#!/bin/sh
# 99-firstboot-setup.sh — 360 V6 初始化脚本

# ── 1. 软件源 ──────────────────────────────────────────────
DIST_ARCH=$(grep "DISTRIB_ARCH" /etc/openwrt_release | cut -d"'" -f2)
[ -z "$DIST_ARCH" ] && DIST_ARCH="aarch64_cortex-a53"

cat > /etc/opkg/distfeeds.conf <<EOF
src/gz openwrt_core https://mirrors.tuna.tsinghua.edu.cn/openwrt/snapshots/targets/qualcommax/ipq60xx/packages
src/gz openwrt_base https://mirrors.tuna.tsinghua.edu.cn/openwrt/snapshots/packages/$DIST_ARCH/base
src/gz openwrt_luci https://mirrors.tuna.tsinghua.edu.cn/openwrt/snapshots/packages/$DIST_ARCH/luci
src/gz openwrt_packages https://mirrors.tuna.tsinghua.edu.cn/openwrt/snapshots/packages/$DIST_ARCH/packages
src/gz openwrt_routing https://mirrors.tuna.tsinghua.edu.cn/openwrt/snapshots/packages/$DIST_ARCH/routing
EOF

# 允许未签名包
sed -i 's/option check_signature/# option check_signature/g' /etc/opkg.conf 2>/dev/null || true

# ── 2. 网络 ────────────────────────────────────────────────
uci set network.lan.ipaddr='192.168.2.1'
uci commit network

# ── 3. 初始化脚本 ──────────────────────────────────────────
cat > /etc/rc.local << 'EOF'
#!/bin/sh
# 延迟等待 USB 设备就绪
sleep 10

# 尝试挂载 U 盘
mount /dev/sda1 /mnt/usb 2>/dev/null || true

if [ -f /mnt/usb/swapfile ]; then
    swapon /mnt/usb/swapfile 2>/dev/null || true
    
    # Docker 数据目录
    mkdir -p /mnt/usb/docker /opt/docker
    mount --bind /mnt/usb/docker /opt/docker 2>/dev/null || true
    
    # HomeProxy 工作目录
    mkdir -p /mnt/usb/homeproxy /etc/homeproxy
    mount --bind /mnt/usb/homeproxy /etc/homeproxy 2>/dev/null || true
    
    # AdGuardHome 数据库
    mkdir -p /mnt/usb/AdGuardHome /etc/AdGuardHome
    mount --bind /mnt/usb/AdGuardHome /etc/AdGuardHome 2>/dev/null || true
fi

# 释放 CPU 性能模式
for cpu_gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    [ -f "$cpu_gov" ] && echo performance > "$cpu_gov" 2>/dev/null || true
done

exit 0
EOF
chmod +x /etc/rc.local

# ── 4. 清理 ────────────────────────────────────────────────
/etc/init.d/dnsfilter disable 2>/dev/null || true

exit 0
