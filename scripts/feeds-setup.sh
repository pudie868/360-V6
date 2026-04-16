#!/bin/sh

# 自动判断当前目录
if [ -f "feeds.conf.default" ]; then
  echo "当前已在 OpenWrt 目录"
else
  cd "$(dirname "$0")/../openwrt" || { echo "错误：无法进入 openwrt 目录"; exit 1; }
fi

FEEDS_FILE="feeds.conf.default"

# 1. 清理旧配置
rm -f $FEEDS_FILE
touch $FEEDS_FILE

# 2. 写入基础官方源
echo "src-git packages https://git.openwrt.org/feed/packages.git" >> $FEEDS_FILE

# 【关键】锁定 Luci 到 openwrt-23.05 分支
echo "src-git luci https://git.openwrt.org/project/luci.git^openwrt-23.05" >> $FEEDS_FILE

echo "src-git routing https://git.openwrt.org/feed/routing.git" >> $FEEDS_FILE
echo "src-git telephony https://git.openwrt.org/feed/telephony.git" >> $FEEDS_FILE
echo "" >> $FEEDS_FILE
echo "# === Custom Feeds ===" >> $FEEDS_FILE

# 3. 写入第三方源
echo "src-git passwall https://fastly.jsdelivr.net/gh/xiaorouji/openwrt-passwall@main" >> $FEEDS_FILE
echo "src-git kiddin9 https://fastly.jsdelivr.net/gh/kiddin9/openwrt-packages@main" >> $FEEDS_FILE

echo "[OK] Feeds config updated."
exit 0
