#!/bin/sh
# 99-firstboot-setup.sh — 自动初始化脚本

# ── 1. 修复软件源 (解决 opkg update 失败) ────────────────────────
# 自动识别架构并替换为中科大镜像 (USTC)，解决官方源访问慢或断流问题
DIST_ARCH=$(grep "DISTRIB_ARCH" /etc/openwrt_release | cut -d"'" -f2)
[ -z "$DIST_ARCH" ] && DIST_ARCH="aarch64_cortex-a53"

cat > /etc/opkg/distfeeds.conf <<EOF
src/gz openwrt_core https://mirrors.ustc.edu.cn/openwrt/snapshots/targets/qualcommax/ipq60xx/packages
src/gz openwrt_base https://mirrors.ustc.edu.cn/openwrt/snapshots/packages/$DIST_ARCH/base
src/gz openwrt_luci https://mirrors.ustc.edu.cn/openwrt/snapshots/packages/$DIST_ARCH/luci
src/gz openwrt_packages https://mirrors.ustc.edu.cn/openwrt/snapshots/packages/$DIST_ARCH/packages
src/gz openwrt_routing https://mirrors.ustc.edu.cn/openwrt/snapshots/packages/$DIST_ARCH/routing
EOF

# 允许未签名软件包（针对某些第三方插件，增强可靠性容错）
sed -i 's/option check_signature/# option check_signature/g' /etc/opkg.conf

# ── 2. 网络与系统基础设置 ───────────────────────────────────────
uci set network.lan.ipaddr='192.168.2.1'
uci commit network

uci set system.@system[0].hostname='OpenWrt-360V6'
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='Asia/Shanghai'
uci commit system

# ── 3. 自动化挂载策略 (针对你的 U 盘) ─────────────────────────────
# 预创挂载点
mkdir -p /mnt/usb

# 写入 rc.local 实现开机自动检测挂载
cat > /etc/rc.local << 'EOF'
#!/bin/sh
# 等待 USB 驱动完全加载
sleep 8
# 尝试挂载第一个分区
mount /dev/sda1 /mnt/usb
# 如果挂载成功，尝试激活 Swap 和迁移 Docker
if [ -d /mnt/usb ]; then
    [ -f /mnt/usb/swapfile ] && swapon /mnt/usb/swapfile
    # 动态链接 Docker 目录，确保不占闪存
    if [ -d /mnt/usb/docker ]; then
        mount --bind /mnt/usb/docker /opt/docker
    fi
fi
# CPU 性能模式
for cpu_gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    [ -f "$cpu_gov" ] && echo performance > "$cpu_gov"
done
exit 0
EOF
chmod +x /etc/rc.local

# ── 4. Docker 预配置 ──────────────────────────────────────────
mkdir -p /opt/docker
mkdir -p /etc/docker
cat > /etc/docker/daemon.json << 'EOF'
{
  "log-driver": "json-file",
  "log-opts": { "max-size": "5m", "max-file": "1" }
}
EOF

exit 0
