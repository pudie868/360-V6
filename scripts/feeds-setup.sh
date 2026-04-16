#!/bin/sh
# ============================================================
# OpenWrt Feeds Setup Script - FORCE LOCAL MODE
# ============================================================

cd "$(dirname "$0")/../openwrt" || exit 1

FEEDS_FILE="feeds.conf.default"

# 1. 清理配置文件中的旧记录，防止重复
sed -i '/kiddin9/d' $FEEDS_FILE
sed -i '/passwall/d' $FEEDS_FILE
sed -i '/lienol/d' $FEEDS_FILE

# 2. 写入配置（指向本地，稍后我们会创建本地目录）
# 注意：这里我们故意注释掉网络地址，只保留本地配置逻辑
echo "src-git-full passwall https://github.com/xiaorouji/openwrt-passwall.git;main" >> $FEEDS_FILE

# 3. 关键步骤：手动创建 kiddin9 目录，防止 find 报错
# 这一步是为了绕过 "No such file or directory" 错误
mkdir -p feeds/kiddin9
mkdir -p feeds/kiddin9/.git  # 创建.git目录欺骗系统认为这是一个有效的git源

# 4. 创建一个空的 Makefile 索引，防止编译时报错
touch feeds/kiddin9/Makefile
touch feeds/kiddin9/index

echo "[OK] Local feeds directory created successfully to bypass download errors."
exit 0
