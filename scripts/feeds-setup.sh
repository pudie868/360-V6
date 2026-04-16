#!/bin/sh
# ============================================================
# OpenWrt Feeds Source Setup Script (Enhanced Version)
# ============================================================

cd "$(dirname "$0")/../openwrt" || exit 1

FEEDS_FILE="feeds.conf.default"

# 1. 备份原始配置文件
if [ ! -f "${FEEDS_FILE}.bak" ]; then
    cp ${FEEDS_FILE} ${FEEDS_FILE}.bak
    echo "[Info] Original config backed up."
fi

# 2. 清理可能存在的旧配置行（防止重复）
# 这一步至关重要，解决 'merging...' 找不到文件的问题
sed -i '/kiddin9/d' ${FEEDS_FILE}
sed -i '/passwall/d' ${FEEDS_FILE}
sed -i '/Custom Feeds/d' ${FEEDS_FILE}

# 3. 写入新配置
echo "" >> ${FEEDS_FILE}
echo "# === Custom Feeds ===" >> ${FEEDS_FILE}

# 添加 kiddin9 源
echo "src-git kiddin9 https://github.com/kiddin9/openwrt-packages.git;main" >> ${FEEDS_FILE}
echo "[OK] kiddin9 feed added."

# 添加 passwall 源
echo "src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main" >> ${FEEDS_FILE}
echo "[OK] passwall feed added."

exit 0
