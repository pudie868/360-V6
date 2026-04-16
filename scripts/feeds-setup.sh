#!/bin/sh
# ============================================================
# OpenWrt Feeds Source Setup Script
# 作用：更新 feeds.conf.default，添加第三方软件源
# 特点：幂等性设计，防止重复添加导致配置混乱
# ============================================================

# 切换到 OpenWrt 源码根目录
cd "$(dirname "$0")/../openwrt" || exit 1

# 定义要添加的第三方源
# kiddin9 源：包含丰富的插件（如 HomeProxy, Argon 主题等）
# sirpdboy 源：包含大量 LuCI 应用 (可选)

# 1. 备份原始配置文件（仅第一次执行时）
if [ ! -f "feeds.conf.default.bak" ]; then
    cp feeds.conf.default feeds.conf.default.bak
    echo "[Info] Original feeds.conf.default backed up."
fi

# 2. 添加 kiddin9 源 (包含大量新特性插件)
# 使用 grep -q 检查是否存在，不存在则追加 (防止重复)
if ! grep -q "src-git kiddin9" feeds.conf.default; then
    echo "" >> feeds.conf.default
    echo "# === Custom Feeds ===" >> feeds.conf.default
    echo "src-git kiddin9 https://github.com/kiddin9/openwrt-packages.git;main" >> feeds.conf.default
    # 如果 kiddin9 依赖 luci 源，确保 luci 也在（官方源默认已包含）
    echo "[OK] kiddin9 feed added."
else
    echo "[Skip] kiddin9 feed already exists."
fi

# 3. 添加 Passwall 源 (如果需要，这里是可选扩展)
# 注意：许多插件依赖 luci，确保官方源在前
if ! grep -q "src-git passwall" feeds.conf.default; then
    echo "src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main" >> feeds.conf.default
    echo "[OK] passwall feed added."
fi

exit 0
