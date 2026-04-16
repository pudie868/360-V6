#!/bin/sh
# ============================================================
# OpenWrt Feeds Setup - 鲁棒版路径修正
# ============================================================

# 自动判断当前目录，如果是 openwrt 目录则直接使用，否则尝试进入
if [ -f "feeds.conf.default" ]; then
    echo "当前已在 OpenWrt 目录"
else
    cd "$(dirname "$0")/../openwrt" || { echo "错误：无法进入 openwrt 目录"; exit 1; }
fi

FEEDS_FILE="feeds.conf.default"

# 1. 清理可能存在的旧配置，防止冲突
rm -f $FEEDS_FILE
touch $FEEDS_FILE

# 2. 写入基础官方源
echo "src-git packages https://git.openwrt.org/feed/packages.git" >> $FEEDS_FILE
echo "src-git luci https://git.openwrt.org/project/luci.git" >> $FEEDS_FILE
echo "src-git routing https://git.openwrt.org/feed/routing.git" >> $FEEDS_FILE
echo "src-git telephony https://git.openwrt.org/feed/telephony.git" >> $FEEDS_FILE

echo "" >> $FEEDS_FILE
echo "# === Custom Feeds (Mirror) ===" >> $FEEDS_FILE

# 3. 写入 Passwall (使用 JSdelivr CDN 加速)
echo "src-git passwall https://fastly.jsdelivr.net/gh/xiaorouji/openwrt-passwall@main" >> $FEEDS_FILE

# 4. 写入 Kiddin9 (使用 JSdelivr CDN 加速)
echo "src-git kiddin9 https://fastly.jsdelivr.net/gh/kiddin9/openwrt-packages@main" >> $FEEDS_FILE

echo "[OK] Feeds config updated with CDN mirror."
exit 0
